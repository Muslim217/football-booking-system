package com.football.booking.repository;

import com.football.booking.entity.Field;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FieldRepository extends JpaRepository<Field, Long> {

    List<Field> findByIsActiveTrue();

    List<Field> findByOwnerId(Long ownerId);

    List<Field> findByOwnerIdAndIsActiveTrue(Long ownerId);
}
