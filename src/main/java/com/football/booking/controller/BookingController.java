package com.football.booking.controller;

import com.football.booking.dto.request.BookingRequest;
import com.football.booking.dto.response.BookingResponse;
import com.football.booking.service.BookingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
@Tag(name = "Бронирования", description = "Управление бронированиями футбольных полей")
public class BookingController {

    private final BookingService bookingService;

    @PostMapping
    @Operation(summary = "Создать бронирование")
    public ResponseEntity<BookingResponse> createBooking(@Valid @RequestBody BookingRequest request,
                                                         Authentication authentication) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(bookingService.createBooking(request, authentication));
    }

    @GetMapping("/my")
    @Operation(summary = "Мои бронирования")
    public ResponseEntity<List<BookingResponse>> getMyBookings(Authentication authentication) {
        return ResponseEntity.ok(bookingService.getMyBookings(authentication));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Все бронирования (только ADMIN)")
    public ResponseEntity<List<BookingResponse>> getAllBookings() {
        return ResponseEntity.ok(bookingService.getAllBookings());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Получить бронирование по ID")
    public ResponseEntity<BookingResponse> getBookingById(@PathVariable Long id,
                                                          Authentication authentication) {
        return ResponseEntity.ok(bookingService.getBookingById(id, authentication));
    }

    @PutMapping("/{id}/cancel")
    @Operation(summary = "Отменить бронирование")
    public ResponseEntity<BookingResponse> cancelBooking(@PathVariable Long id,
                                                         Authentication authentication) {
        return ResponseEntity.ok(bookingService.cancelBooking(id, authentication));
    }

    @GetMapping("/field/{fieldId}")
    @Operation(summary = "Бронирования по полю (проверка доступности)")
    public ResponseEntity<List<BookingResponse>> getBookingsByField(@PathVariable Long fieldId) {
        return ResponseEntity.ok(bookingService.getBookingsByField(fieldId));
    }
}
