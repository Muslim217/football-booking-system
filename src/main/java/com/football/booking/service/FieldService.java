package com.football.booking.service;

import com.football.booking.dto.request.FieldRequest;
import com.football.booking.dto.response.FieldResponse;
import com.football.booking.entity.Field;
import com.football.booking.entity.User;
import com.football.booking.enums.Role;
import com.football.booking.exception.AccessDeniedException;
import com.football.booking.exception.ResourceNotFoundException;
import com.football.booking.repository.FieldRepository;
import com.football.booking.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FieldService {

    private final FieldRepository fieldRepository;
    private final UserRepository userRepository;

    // === Публичные методы ===

    public List<FieldResponse> getAllActiveFields() {
        return fieldRepository.findByIsActiveTrue()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public FieldResponse getFieldById(Long id) {
        Field field = fieldRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Поле не найдено с ID: " + id));
        return mapToResponse(field);
    }

    // === Методы владельца (OWNER) ===

    public List<FieldResponse> getMyFields(Authentication authentication) {
        User owner = getAuthenticatedUser(authentication);
        return fieldRepository.findByOwnerId(owner.getId())
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public FieldResponse createField(FieldRequest request, Authentication authentication) {
        User owner = getAuthenticatedUser(authentication);

        // Только OWNER и ADMIN могут создавать поля
        if (owner.getRole() != Role.OWNER && owner.getRole() != Role.ADMIN) {
            throw new AccessDeniedException("Только владельцы полей могут создавать поля");
        }

        Field field = Field.builder()
                .name(request.getName())
                .address(request.getAddress())
                .fieldType(request.getFieldType())
                .pricePerHour(request.getPricePerHour())
                .description(request.getDescription())
                .owner(owner)
                .isActive(true)
                .build();

        Field saved = fieldRepository.save(field);
        return mapToResponse(saved);
    }

    @Transactional
    public FieldResponse updateField(Long id, FieldRequest request, Authentication authentication) {
        Field field = fieldRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Поле не найдено с ID: " + id));

        checkOwnership(field, authentication);

        field.setName(request.getName());
        field.setAddress(request.getAddress());
        field.setFieldType(request.getFieldType());
        field.setPricePerHour(request.getPricePerHour());
        field.setDescription(request.getDescription());

        Field updated = fieldRepository.save(field);
        return mapToResponse(updated);
    }

    @Transactional
    public void deactivateField(Long id, Authentication authentication) {
        Field field = fieldRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Поле не найдено с ID: " + id));

        checkOwnership(field, authentication);

        field.setIsActive(false);
        fieldRepository.save(field);
    }

    @Transactional
    public void activateField(Long id, Authentication authentication) {
        Field field = fieldRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Поле не найдено с ID: " + id));

        checkOwnership(field, authentication);

        field.setIsActive(true);
        fieldRepository.save(field);
    }

    // === Вспомогательные методы ===

    private User getAuthenticatedUser(Authentication authentication) {
        return userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new ResourceNotFoundException("Пользователь не найден"));
    }

    private void checkOwnership(Field field, Authentication authentication) {
        User user = getAuthenticatedUser(authentication);
        boolean isAdmin = user.getRole() == Role.ADMIN;
        boolean isOwner = field.getOwner().getId().equals(user.getId());

        if (!isOwner && !isAdmin) {
            throw new AccessDeniedException("Вы можете управлять только своими полями");
        }
    }

    private FieldResponse mapToResponse(Field field) {
        return FieldResponse.builder()
                .id(field.getId())
                .name(field.getName())
                .address(field.getAddress())
                .fieldType(field.getFieldType())
                .pricePerHour(field.getPricePerHour())
                .description(field.getDescription())
                .isActive(field.getIsActive())
                .ownerUsername(field.getOwner().getUsername())
                .createdAt(field.getCreatedAt())
                .build();
    }
}
