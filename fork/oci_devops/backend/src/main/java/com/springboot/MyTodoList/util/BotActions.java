package com.springboot.MyTodoList.util;

import com.ociproject.model.Task;
import com.ociproject.service.TaskService;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.ReplyKeyboardMarkup;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.buttons.KeyboardRow;
import org.telegram.telegrambots.meta.generics.TelegramClient;

public class BotActions {

    private static final Logger logger = LoggerFactory.getLogger(BotActions.class);

    String requestText;
    long chatId;
    TelegramClient telegramClient;
    boolean exit;

    TaskService taskService;

    public BotActions(TelegramClient tc, TaskService ts) {
        telegramClient = tc;
        taskService = ts;
        exit = false;
    }

    public void setRequestText(String cmd) { requestText = cmd; }
    public void setChatId(long chId)       { chatId = chId; }
    public void setTelegramClient(TelegramClient tc) { telegramClient = tc; }
    public void setTaskService(TaskService ts)       { taskService = ts; }
    public TaskService getTaskService()              { return taskService; }

    public void fnStart() {
        if (!(requestText.equals(BotCommands.START_COMMAND.getCommand())
                || requestText.equals(BotLabels.SHOW_MAIN_SCREEN.getLabel())) || exit)
            return;

        BotHelper.sendMessageToTelegram(chatId, BotMessages.HELLO_MYTODO_BOT.getMessage(), telegramClient,
                ReplyKeyboardMarkup
                        .builder()
                        .keyboardRow(new KeyboardRow(BotLabels.LIST_ALL_ITEMS.getLabel(), BotLabels.ADD_NEW_ITEM.getLabel()))
                        .keyboardRow(new KeyboardRow(BotLabels.SHOW_MAIN_SCREEN.getLabel(), BotLabels.HIDE_MAIN_SCREEN.getLabel()))
                        .build());
        exit = true;
    }

    public void fnDone() {
        if (!(requestText.indexOf(BotLabels.DONE.getLabel()) != -1) || exit)
            return;

        String done = requestText.substring(0, requestText.indexOf(BotLabels.DASH.getLabel()));
        Long id = Long.valueOf(done);

        try {
            Task task = taskService.findById(id)
                    .orElseThrow(() -> new RuntimeException("Task not found: " + id));
            task.setStatus(Task.Status.DONE);
            taskService.save(task);
            BotHelper.sendMessageToTelegram(chatId, BotMessages.ITEM_DONE.getMessage(), telegramClient);
        } catch (Exception e) {
            logger.error(e.getLocalizedMessage(), e);
        }
        exit = true;
    }

    public void fnUndo() {
        if (requestText.indexOf(BotLabels.UNDO.getLabel()) == -1 || exit)
            return;

        String undo = requestText.substring(0, requestText.indexOf(BotLabels.DASH.getLabel()));
        Long id = Long.valueOf(undo);

        try {
            Task task = taskService.findById(id)
                    .orElseThrow(() -> new RuntimeException("Task not found: " + id));
            task.setStatus(Task.Status.PENDING);
            taskService.save(task);
            BotHelper.sendMessageToTelegram(chatId, BotMessages.ITEM_UNDONE.getMessage(), telegramClient);
        } catch (Exception e) {
            logger.error(e.getLocalizedMessage(), e);
        }
        exit = true;
    }

    public void fnDelete() {
        if (requestText.indexOf(BotLabels.DELETE.getLabel()) == -1 || exit)
            return;

        String delete = requestText.substring(0, requestText.indexOf(BotLabels.DASH.getLabel()));
        Long id = Long.valueOf(delete);

        try {
            taskService.softDelete(id);
            BotHelper.sendMessageToTelegram(chatId, BotMessages.ITEM_DELETED.getMessage(), telegramClient);
        } catch (Exception e) {
            logger.error(e.getLocalizedMessage(), e);
        }
        exit = true;
    }

    public void fnHide() {
        if (requestText.equals(BotCommands.HIDE_COMMAND.getCommand())
                || requestText.equals(BotLabels.HIDE_MAIN_SCREEN.getLabel()) && !exit)
            BotHelper.sendMessageToTelegram(chatId, BotMessages.BYE.getMessage(), telegramClient);
        else
            return;
        exit = true;
    }

    public void fnListAll() {
        if (!(requestText.equals(BotCommands.TODO_LIST.getCommand())
                || requestText.equals(BotLabels.LIST_ALL_ITEMS.getLabel())
                || requestText.equals(BotLabels.MY_TODO_LIST.getLabel())) || exit)
            return;

        List<Task> allItems = taskService.findAll();
        ReplyKeyboardMarkup keyboardMarkup = ReplyKeyboardMarkup.builder()
                .resizeKeyboard(true)
                .oneTimeKeyboard(false)
                .selective(true)
                .build();

        List<KeyboardRow> keyboard = new ArrayList<>();

        KeyboardRow mainScreenRowTop = new KeyboardRow();
        mainScreenRowTop.add(BotLabels.SHOW_MAIN_SCREEN.getLabel());
        keyboard.add(mainScreenRowTop);

        KeyboardRow firstRow = new KeyboardRow();
        firstRow.add(BotLabels.ADD_NEW_ITEM.getLabel());
        keyboard.add(firstRow);

        KeyboardRow myTodoListTitleRow = new KeyboardRow();
        myTodoListTitleRow.add(BotLabels.MY_TODO_LIST.getLabel());
        keyboard.add(myTodoListTitleRow);

        List<Task> pendingItems = allItems.stream()
                .filter(t -> t.getStatus() != Task.Status.DONE)
                .collect(Collectors.toList());

        for (Task task : pendingItems) {
            KeyboardRow currentRow = new KeyboardRow();
            currentRow.add(task.getTitle());
            currentRow.add(task.getTaskId() + BotLabels.DASH.getLabel() + BotLabels.DONE.getLabel());
            keyboard.add(currentRow);
        }

        List<Task> doneItems = allItems.stream()
                .filter(t -> t.getStatus() == Task.Status.DONE)
                .collect(Collectors.toList());

        for (Task task : doneItems) {
            KeyboardRow currentRow = new KeyboardRow();
            currentRow.add(task.getTitle());
            currentRow.add(task.getTaskId() + BotLabels.DASH.getLabel() + BotLabels.UNDO.getLabel());
            currentRow.add(task.getTaskId() + BotLabels.DASH.getLabel() + BotLabels.DELETE.getLabel());
            keyboard.add(currentRow);
        }

        KeyboardRow mainScreenRowBottom = new KeyboardRow();
        mainScreenRowBottom.add(BotLabels.SHOW_MAIN_SCREEN.getLabel());
        keyboard.add(mainScreenRowBottom);

        keyboardMarkup.setKeyboard(keyboard);

        BotHelper.sendMessageToTelegram(chatId, BotLabels.MY_TODO_LIST.getLabel(), telegramClient, keyboardMarkup);
        exit = true;
    }

    public void fnAddItem() {
        if (!(requestText.contains(BotCommands.ADD_ITEM.getCommand())
                || requestText.contains(BotLabels.ADD_NEW_ITEM.getLabel())) || exit)
            return;
        BotHelper.sendMessageToTelegram(chatId, BotMessages.TYPE_NEW_TODO_ITEM.getMessage(), telegramClient);
        exit = true;
    }

    public void fnElse() {
        if (exit)
            return;
        Task newTask = new Task();
        newTask.setTitle(requestText);
        newTask.setStatus(Task.Status.PENDING);
        taskService.save(newTask);
        BotHelper.sendMessageToTelegram(chatId, BotMessages.NEW_ITEM_ADDED.getMessage(), telegramClient, null);
    }

    public void fnLLM() {
        if (!(requestText.contains(BotCommands.LLM_REQ.getCommand())) || exit)
            return;
        BotHelper.sendMessageToTelegram(chatId, "LLM integration not available in this version.", telegramClient, null);
        exit = true;
    }
}
