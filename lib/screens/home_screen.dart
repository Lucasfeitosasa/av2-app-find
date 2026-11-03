import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../state/item_controller.dart';
import 'register_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.controller, super.key});

  final ItemController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achados e Perdidos'),
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
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList.separated(
                  itemCount: controller.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _ItemCard(item: controller.items[index]),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRegistration,
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar objeto'),
      ),
    );
  }

  Widget _header(BuildContext context, int count) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mural do campus',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 7),
        Text(
          '$count ${count == 1 ? 'registro publicado' : 'registros publicados'}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final LostItem item;

  @override
  Widget build(BuildContext context) {
    final isFound = item.status == ItemStatus.found;
    final color = isFound ? const Color(0xFF176B52) : const Color(0xFF9B4D16);
    final background = isFound
        ? const Color(0xFFE4F3EA)
        : const Color(0xFFFFF0DF);
    final date = item.createdAt.toLocal();
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE6EAE7)),
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
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(item.location)),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall,
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
  const _EmptyState();

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
            'Nenhum objeto cadastrado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 7),
          const Text(
            'Os registros publicados no campus aparecerão aqui.',
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
