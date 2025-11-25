import '../repositories/chat_repository.dart';

class FetchServicesUseCase {
  final ChatRepository repository;

  FetchServicesUseCase(this.repository);

  // Future<List<dynamic>> call() {
  //   // return repository.fetchServices();
  // }
}