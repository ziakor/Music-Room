class ReturnRepository {
  final String message;
  final bool status;
  final Map<String, dynamic> data;

  const ReturnRepository.success(
      {this.status = true, this.message = "", this.data = const {}});

  const ReturnRepository.failed(
      {this.status = false, required this.message, this.data = const {}});
}
