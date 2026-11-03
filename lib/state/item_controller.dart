import 'package:flutter/foundation.dart';

import '../data/item_repository.dart';
import '../models/lost_item.dart';

class ItemController extends ChangeNotifier {
  ItemController(this._repository);

  final ItemRepository _repository;
  final List<LostItem> _items = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<LostItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadItems() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final items = await _repository.fetchItems();
      _items
        ..clear()
        ..addAll(items);
      _hasLoaded = true;
    } on ItemRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage =
          'Não foi possível carregar os registros. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createItem({
    required String name,
    required String description,
    required String location,
    required ItemStatus status,
  }) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final item = LostItem(
        id: '',
        name: name.trim(),
        description: description.trim(),
        location: location.trim(),
        status: status,
        createdAt: DateTime.now(),
      );
      final saved = await _repository.createItem(item);
      _items
        ..removeWhere((current) => current.id == saved.id)
        ..add(saved)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _hasLoaded = true;
      return true;
    } on ItemRepositoryException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o registro. Tente novamente.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  bool get hasLoaded => _hasLoaded;
}
