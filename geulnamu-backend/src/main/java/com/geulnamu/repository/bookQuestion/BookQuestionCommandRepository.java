package com.geulnamu.repository.bookQuestion;

import com.geulnamu.domain.bookQuestion.BookQuestion;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookQuestionCommandRepository extends JpaRepository<BookQuestion, Long> {
}
