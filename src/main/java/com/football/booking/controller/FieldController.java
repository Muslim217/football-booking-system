package com.football.booking.controller;

import com.football.booking.dto.request.FieldRequest;
import com.football.booking.dto.response.FieldResponse;
import com.football.booking.dto.response.MessageResponse;
import com.football.booking.service.FieldService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/fields")
@RequiredArgsConstructor
@Tag(name = "Футбольные поля", description = "Управление футбольными полями")
public class FieldController {

    private final FieldService fieldService;

    @GetMapping
    @Operation(summary = "Получить все активные поля")
    public ResponseEntity<List<FieldResponse>> getAllFields() {
        return ResponseEntity.ok(fieldService.getAllActiveFields());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Получить поле по ID")
    public ResponseEntity<FieldResponse> getFieldById(@PathVariable Long id) {
        return ResponseEntity.ok(fieldService.getFieldById(id));
    }

    @PostMapping
    @Operation(summary = "Создать новое поле (только ADMIN)")
    public ResponseEntity<FieldResponse> createField(@Valid @RequestBody FieldRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(fieldService.createField(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Обновить поле (только ADMIN)")
    public ResponseEntity<FieldResponse> updateField(@PathVariable Long id,
                                                     @Valid @RequestBody FieldRequest request) {
        return ResponseEntity.ok(fieldService.updateField(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Деактивировать поле (только ADMIN)")
    public ResponseEntity<MessageResponse> deactivateField(@PathVariable Long id) {
        fieldService.deactivateField(id);
        return ResponseEntity.ok(new MessageResponse("Поле успешно деактивировано"));
    }
}
