import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../state/item_controller.dart';
import 'register_screen.dart';

enum _StatusFilter { all, lost, found }

enum _DateOrder { newest, oldest }

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.controller, super.key});

  final ItemController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _StatusFilter _statusFilter = _StatusFilter.all;
  _DateOrder _dateOrder = _DateOrder.newest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadItems();
    });
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  Future<void> _openRegistration() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final visibleItems = controller.items.where((item) {
      return switch (_statusFilter) {
        _StatusFilter.all => true,
        _StatusFilter.lost => item.status == ItemStatus.lost,
        _StatusFilter.found => item.status == ItemStatus.found,
      };
    }).toList()..sort((a, b) {
      final comparison = a.createdAt.compareTo(b.createdAt);
      return _dateOrder == _DateOrder.newest ? -comparison : comparison;
    });
    return Scaffold(
      appBar: AppBar(
        title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Text(
            'Achados e Perdidos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF183153),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar registros',
            onPressed: controller.isLoading ? null : controller.loadItems,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadItems,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _header(context, controller.items.length),
            ),
            if (controller.isLoading && !controller.hasLoaded)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.errorMessage != null &&
                controller.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  message: controller.errorMessage!,
                  onRetry: controller.loadItems,
                ),
              )
            else if (controller.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else if (visibleItems.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(filtered: true),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList.separated(
                  itemCount: visibleItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _ItemCard(item: visibleItems[index]),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRegistration,
        backgroundColor: const Color(0xFF183153),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar objeto'),
      ),
    );
  }

  Widget _header(BuildContext context, int count) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mural do campus',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: const Color(0xFF183153), fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '$count ${count == 1 ? 'registro publicado' : 'registros publicados'}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF183153), fontSize: 15, fontWeight: FontWeight.w600
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statusFilterButton('Todos', _StatusFilter.all),
            const SizedBox(width: 8),
            _statusFilterButton('Perdidos', _StatusFilter.lost),
            const SizedBox(width: 8),
            _statusFilterButton('Encontrados', _StatusFilter.found),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                _dateOrder == _DateOrder.newest
                    ? 'PUBLICAÇÕES RECENTES'
                    : 'PUBLICAÇÕES MAIS ANTIGAS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF66758C),
                  letterSpacing: 0.4,
                ),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<_DateOrder>(
                value: _dateOrder,
                isDense: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF66758C),
                ),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF66758C),
                ),
                items: const [
                  DropdownMenuItem(
                    value: _DateOrder.newest,
                    child: Text('Mais recentes'),
                  ),
                  DropdownMenuItem(
                    value: _DateOrder.oldest,
                    child: Text('Mais antigos'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _dateOrder = value);
                },
              ),
            ),
          ],
        ),
        if (widget.controller.isLoading && widget.controller.hasLoaded)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(),
          ),
        if (widget.controller.errorMessage != null &&
            widget.controller.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: MaterialBanner(
              content: Text(widget.controller.errorMessage!),
              actions: [
                TextButton(
                  onPressed: widget.controller.loadItems,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _statusFilterButton(String label, _StatusFilter filter) {
    final isSelected = _statusFilter == filter;
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => _statusFilter = filter),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF183153) : Colors.white,
          foregroundColor: isSelected ? Colors.white : const Color(0xFF66758C),
          minimumSize: const Size.fromHeight(38),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF183153)
                  : const Color(0xFFDCE3ED),
            ),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final LostItem item;

  @override
  Widget build(BuildContext context) {
    final isFound = item.status == ItemStatus.found;
    final color = isFound ? const Color(0xFF13795B) : const Color(0xFFB85A1B);
    final background = isFound
        ? const Color(0xFFE7F4EE)
        : const Color(0xFFFFF1E6);
    final date = item.createdAt.toLocal();
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFDCE3ED)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  item.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF183153),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    item.status.label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: Color(0xFF66758C),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(item.location)),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: Color(0xFF66758C),
                ),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF66758C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.filtered = false});

  final bool filtered;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            filtered ? 'Nenhum objeto nessa categoria' : 'Nenhum objeto cadastrado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 7),
          Text(
            filtered
                ? 'Escolha outra situação para ver os registros disponíveis.'
                : 'Os registros publicados no campus aparecerão aqui.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}
