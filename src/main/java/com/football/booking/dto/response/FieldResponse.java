package com.football.booking.dto.response;

import com.football.booking.enums.FieldType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FieldResponse {

    private Long id;
    private String name;
    private String address;
    private FieldType fieldType;
    private BigDecimal pricePerHour;
    private String description;
    private Boolean isActive;
    private LocalDateTime createdAt;
}
