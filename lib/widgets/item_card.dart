import 'package:flutter/material.dart';

import '../models/lost_item.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({required this.item, super.key});

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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
