package com.football.booking.service;

import com.football.booking.dto.request.FieldRequest;
import com.football.booking.dto.response.FieldResponse;
import com.football.booking.entity.Field;
import com.football.booking.exception.ResourceNotFoundException;
import com.football.booking.repository.FieldRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FieldService {

    private final FieldRepository fieldRepository;

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

    @Transactional
    public FieldResponse createField(FieldRequest request) {
        Field field = Field.builder()
                .name(request.getName())
                .address(request.getAddress())
                .fieldType(request.getFieldType())
                .pricePerHour(request.getPricePerHour())
                .description(request.getDescription())
                .isActive(true)
                .build();

        Field saved = fieldRepository.save(field);
        return mapToResponse(saved);
    }

    @Transactional
    public FieldResponse updateField(Long id, FieldRequest request) {
        Field field = fieldRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Поле не найдено с ID: " + id));

        field.setName(request.getName());
        field.setAddress(request.getAddress());
        field.setFieldType(request.getFieldType());
        field.setPricePerHour(request.getPricePerHour());
        field.setDescription(request.getDescription());

        Field updated = fieldRepository.save(field);
        return mapToResponse(updated);
    }

    @Transactional
    public void deactivateField(Long id) {
        Field field = fieldRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Поле не найдено с ID: " + id));
        field.setIsActive(false);
        fieldRepository.save(field);
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
                .createdAt(field.getCreatedAt())
                .build();
    }
}
