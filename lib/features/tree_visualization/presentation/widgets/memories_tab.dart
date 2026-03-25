import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MemoriesTab extends StatefulWidget {
  const MemoriesTab({super.key});

  @override
  State<MemoriesTab> createState() => _MemoriesTabState();
}

class _MemoriesTabState extends State<MemoriesTab> {
  String _selectedYear = '2024';
  final List<String> _years = ['2021', '2022', '2023', '2024'];

  // Mock data for memories
  final List<Map<String, String>> _mockMemories = [
    {
      'url': 'https://picsum.photos/seed/mem1/400/400',
      'title': 'Family Reunion',
      'date': 'Oct 12, 2024',
    },
    {
      'url': 'https://picsum.photos/seed/mem2/400/400',
      'title': 'Grandma\'s Birthday',
      'date': 'Aug 25, 2024',
    },
    {
      'url': 'https://picsum.photos/seed/mem3/400/400',
      'title': 'Summer Trip',
      'date': 'Jul 15, 2024',
    },
    {
      'url': 'https://picsum.photos/seed/mem4/400/400',
      'title': 'New House',
      'date': 'Feb 10, 2024',
    },
    {
      'url': 'https://picsum.photos/seed/mem5/400/400',
      'title': 'Christmas Eve',
      'date': 'Dec 24, 2023',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Year Selector
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                'Browse by year:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedYear,
                    items: _years.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedYear = value);
                    },
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Grid of Memories
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _mockMemories.length,
            itemBuilder: (context, index) {
              final memory = _mockMemories[index];
              return _buildMemoryCard(memory);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryCard(Map<String, String> memory) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: memory['url']!,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  memory['date']!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
