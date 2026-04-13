package com.ociproject.security;

import com.ociproject.model.User;
import com.ociproject.service.UserService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider tokenProvider;
    private final UserService userService;

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain)
            throws ServletException, IOException {

        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);
            if (tokenProvider.validateToken(token) && !tokenProvider.isRefreshToken(token)) {
                Long userId = tokenProvider.getUserIdFromToken(token);
                userService.findById(userId).ifPresent(user -> {
                    String roleName = user.getRole() != null ? user.getRole().getRoleName() : "USER";
                    var auth = new UsernamePasswordAuthenticationToken(
                            user,
                            null,
                            List.of(new SimpleGrantedAuthority("ROLE_" + roleName))
                    );
                    SecurityContextHolder.getContext().setAuthentication(auth);
                });
            }
        }
        filterChain.doFilter(request, response);
    }
}
