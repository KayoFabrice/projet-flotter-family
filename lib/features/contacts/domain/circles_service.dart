import '../data/circles_repository.dart';
import 'contact_circle.dart';

class CirclesService {
  CirclesService(this._repository);

  final CirclesRepository _repository;

  Future<List<ContactCircle>> loadSelectedCircles() {
    return _repository.fetchSelectedCircles();
  }

  Future<void> saveSelectedCircles(List<ContactCircle> circles) {
    return _repository.saveSelectedCircles(circles);
  }
}
