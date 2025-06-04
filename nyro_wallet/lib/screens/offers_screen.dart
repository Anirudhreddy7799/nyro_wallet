import 'package:flutter/material.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Offers', style: TextStyle(color: Color(0xFFE5C100))),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: true,
                    onSelected: (value) {},
                    selectedColor: const Color(0xFFE5C100),
                    backgroundColor: const Color(0xFF1A1A1A),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Dining'),
                    selected: false,
                    onSelected: (value) {},
                    backgroundColor: const Color(0xFF1A1A1A),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Travel'),
                    selected: false,
                    onSelected: (value) {},
                    backgroundColor: const Color(0xFF1A1A1A),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Groceries'),
                    selected: false,
                    onSelected: (value) {},
                    backgroundColor: const Color(0xFF1A1A1A),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Offers List
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with dynamic data later
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFFE5C100),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        'Offer ${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Get 20% off on your next purchase',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.local_offer,
                        color: Color(0xFFE5C100),
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
