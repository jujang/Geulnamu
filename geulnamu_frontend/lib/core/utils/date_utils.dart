import 'package:intl/intl.dart';

/// 날짜 관련 유틸리티 클래스
/// 
/// 생년월일 형식 변환 기능 제공:
/// - 표시용: "2022-01-01" → "2022년 1월 1일"
/// - API용: DateTime → "20220101"
class DateUtils {
  DateUtils._(); // private constructor - static class

  /// 백엔드 조회 형식("2022-01-01")을 한국어 표시 형식으로 변환
  /// 
  /// Example: "2022-01-01" → "2022년 1월 1일"
  static String formatDisplayDate(String backendDate) {
    try {
      // "2022-01-01" 형식 파싱
      final DateTime dateTime = DateTime.parse(backendDate);
      return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일';
    } catch (e) {
      print('❌ [DateUtils] 날짜 파싱 오류: $backendDate, $e');
      return backendDate; // 파싱 실패시 원본 반환
    }
  }

  /// DateTime을 백엔드 수정 형식("20220101")으로 변환
  /// 
  /// Example: DateTime(2022, 1, 1) → "20220101"
  static String formatApiDate(DateTime dateTime) {
    try {
      return DateFormat('yyyyMMdd').format(dateTime);
    } catch (e) {
      print('❌ [DateUtils] API 날짜 형식 변환 오류: $dateTime, $e');
      return '';
    }
  }

  /// 백엔드 조회 형식("2022-01-01")을 DateTime으로 변환
  /// 
  /// DatePicker에서 사용하기 위함
  static DateTime? parseBackendDate(String backendDate) {
    try {
      return DateTime.parse(backendDate);
    } catch (e) {
      print('❌ [DateUtils] DateTime 파싱 오류: $backendDate, $e');
      return null;
    }
  }

  /// 백엔드 조회 형식("2022-01-01")을 수정용 형식("20220101")으로 변환
  /// 
  /// 기존 데이터를 수정할 때 사용
  static String convertDisplayToApi(String backendDate) {
    try {
      final DateTime? dateTime = parseBackendDate(backendDate);
      if (dateTime != null) {
        return formatApiDate(dateTime);
      }
      return '';
    } catch (e) {
      print('❌ [DateUtils] 형식 변환 오류: $backendDate, $e');
      return '';
    }
  }

  /// 날짜 유효성 검증
  /// 
  /// - 현재 날짜보다 과거여야 함
  /// - 너무 오래된 날짜는 제외 (1900년 이후)
  static bool isValidBirthDate(DateTime date) {
    final now = DateTime.now();
    final minDate = DateTime(1900, 1, 1);
    
    return date.isBefore(now) && date.isAfter(minDate);
  }

  /// 나이 계산
  /// 
  /// 생년월일로부터 현재 나이 계산
  static int calculateAge(String birthDateString) {
    try {
      final birthDate = parseBackendDate(birthDateString);
      if (birthDate == null) return 0;
      
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      
      // 생일이 지나지 않았으면 1살 빼기
      if (now.month < birthDate.month || 
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      
      return age;
    } catch (e) {
      print('❌ [DateUtils] 나이 계산 오류: $birthDateString, $e');
      return 0;
    }
  }
}
