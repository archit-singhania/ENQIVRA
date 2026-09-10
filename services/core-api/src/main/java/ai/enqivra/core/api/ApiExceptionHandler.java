package ai.enqivra.core.api;

import java.time.Instant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ApiExceptionHandler {
  private static final Logger log = LoggerFactory.getLogger(ApiExceptionHandler.class);

  @ExceptionHandler(NotFoundException.class)
  ResponseEntity<ApiError> handleNotFound(NotFoundException exception) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(new ApiError(404, "Not Found", exception.getMessage(), Instant.now()));
  }

  @ExceptionHandler(ForbiddenException.class)
  ResponseEntity<ApiError> handleForbidden(ForbiddenException exception) {
    return ResponseEntity.status(HttpStatus.FORBIDDEN)
        .body(new ApiError(403, "Forbidden", exception.getMessage(), Instant.now()));
  }

  @ExceptionHandler({IllegalArgumentException.class, MethodArgumentNotValidException.class})
  ResponseEntity<ApiError> handleBadRequest(Exception exception) {
    return ResponseEntity.badRequest()
        .body(new ApiError(400, "Bad Request", exception.getMessage(), Instant.now()));
  }

  @ExceptionHandler(Exception.class)
  ResponseEntity<ApiError> handleUnexpected(Exception exception) {
    log.error("Unhandled request failure", exception);
    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
        .body(
            new ApiError(
                500, "Internal Server Error", "An unexpected error occurred", Instant.now()));
  }
}
