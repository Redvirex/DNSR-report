import 'package:flutter/material.dart';

class WilayaFilterDropdown extends StatelessWidget {
  final String? selectedWilaya;
  final List<String> availableWilayas;
  final ValueChanged<String?> onWilayaChanged;

  const WilayaFilterDropdown({
    super.key,
    required this.selectedWilaya,
    required this.availableWilayas,
    required this.onWilayaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String?>(
        value: selectedWilaya,
        hint: const Text('Wilaya: Toutes'),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Toutes les wilayas'),
          ),
          ...availableWilayas.map((wilaya) {
            return DropdownMenuItem<String?>(
              value: wilaya,
              child: Text(wilaya),
            );
          }),
        ],
        onChanged: onWilayaChanged,
      ),
    );
  }
}
