package com.football.booking.dto.request;

import com.football.booking.enums.FieldType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FieldRequest {

    @NotBlank(message = "Название поля обязательно")
    private String name;

    @NotBlank(message = "Адрес обязателен")
    private String address;

    @NotNull(message = "Тип поля обязателен")
    private FieldType fieldType;

    @NotNull(message = "Цена за час обязательна")
    @Positive(message = "Цена должна быть положительной")
    private BigDecimal pricePerHour;

    private String description;
}
