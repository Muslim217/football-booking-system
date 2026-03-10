package com.football.booking.service;

import com.football.booking.dto.request.BookingRequest;
import com.football.booking.dto.response.BookingResponse;
import com.football.booking.entity.Booking;
import com.football.booking.entity.Field;
import com.football.booking.entity.User;
import com.football.booking.enums.BookingStatus;
import com.football.booking.exception.AccessDeniedException;
import com.football.booking.exception.BookingConflictException;
import com.football.booking.exception.ResourceNotFoundException;
import com.football.booking.repository.BookingRepository;
import com.football.booking.repository.FieldRepository;
import com.football.booking.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingRepository bookingRepository;
    private final FieldRepository fieldRepository;
    private final UserRepository userRepository;

    @Transactional
    public BookingResponse createBooking(BookingRequest request, Authentication authentication) {
        String username = authentication.getName();

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Пользователь не найден"));

        Field field = fieldRepository.findById(request.getFieldId())
                .orElseThrow(() -> new ResourceNotFoundException("Поле не найдено с ID: " + request.getFieldId()));

        if (!field.getIsActive()) {
            throw new IllegalArgumentException("Поле неактивно и недоступно для бронирования");
        }

        if (request.getEndTime().isBefore(request.getStartTime()) ||
                request.getEndTime().isEqual(request.getStartTime())) {
            throw new IllegalArgumentException("Время окончания должно быть после времени начала");
        }

        // Проверка пересечений
        List<Booking> conflicts = bookingRepository.findConflictingBookings(
                request.getFieldId(), request.getStartTime(), request.getEndTime());

        if (!conflicts.isEmpty()) {
            throw new BookingConflictException(
                    "Поле уже забронировано на указанное время. Количество пересечений: " + conflicts.size());
        }

        // Расчёт стоимости
        long minutes = Duration.between(request.getStartTime(), request.getEndTime()).toMinutes();
        BigDecimal hours = BigDecimal.valueOf(minutes).divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
        BigDecimal totalPrice = field.getPricePerHour().multiply(hours).setScale(2, RoundingMode.HALF_UP);

        Booking booking = Booking.builder()
                .user(user)
                .field(field)
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .totalPrice(totalPrice)
                .status(BookingStatus.CONFIRMED)
                .build();

        Booking saved = bookingRepository.save(booking);
        return mapToResponse(saved);
    }

    public List<BookingResponse> getMyBookings(Authentication authentication) {
        String username = authentication.getName();
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Пользователь не найден"));

        return bookingRepository.findByUserId(user.getId())
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<BookingResponse> getAllBookings() {
        return bookingRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public BookingResponse getBookingById(Long id, Authentication authentication) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Бронирование не найдено с ID: " + id));

        String username = authentication.getName();
        boolean isAdmin = authentication.getAuthorities()
                .contains(new SimpleGrantedAuthority("ROLE_ADMIN"));

        if (!booking.getUser().getUsername().equals(username) && !isAdmin) {
            throw new AccessDeniedException("У вас нет доступа к этому бронированию");
        }

        return mapToResponse(booking);
    }

    @Transactional
    public BookingResponse cancelBooking(Long id, Authentication authentication) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Бронирование не найдено с ID: " + id));

        String username = authentication.getName();
        boolean isAdmin = authentication.getAuthorities()
                .contains(new SimpleGrantedAuthority("ROLE_ADMIN"));

        if (!booking.getUser().getUsername().equals(username) && !isAdmin) {
            throw new AccessDeniedException("У вас нет прав для отмены этого бронирования");
        }

        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new IllegalArgumentException("Бронирование уже отменено");
        }

        booking.setStatus(BookingStatus.CANCELLED);
        Booking updated = bookingRepository.save(booking);
        return mapToResponse(updated);
    }

    public List<BookingResponse> getBookingsByField(Long fieldId) {
        if (!fieldRepository.existsById(fieldId)) {
            throw new ResourceNotFoundException("Поле не найдено с ID: " + fieldId);
        }

        return bookingRepository.findByFieldId(fieldId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private BookingResponse mapToResponse(Booking booking) {
        return BookingResponse.builder()
                .id(booking.getId())
                .username(booking.getUser().getUsername())
                .fieldId(booking.getField().getId())
                .fieldName(booking.getField().getName())
                .startTime(booking.getStartTime())
                .endTime(booking.getEndTime())
                .totalPrice(booking.getTotalPrice())
                .status(booking.getStatus())
                .createdAt(booking.getCreatedAt())
                .build();
    }
}
