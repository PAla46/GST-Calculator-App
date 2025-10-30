import 'package:flutter/material.dart';

void main() {
  runApp(const GSTCalculatorApp());
}

class GSTCalculatorApp extends StatelessWidget {
  const GSTCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GST Calculator',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const GSTCalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GSTCalculatorScreen extends StatefulWidget {
  const GSTCalculatorScreen({super.key});

  @override
  State<GSTCalculatorScreen> createState() => _GSTCalculatorScreenState();
}

class _GSTCalculatorScreenState extends State<GSTCalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  double? beforeTax, afterTax, totalGST, cgst, sgst;
  final double gstRate = 18.0;

  String calcMode = 'after'; // 'after' or 'before'

  void calculateGST() {
    final input = double.tryParse(_amountController.text);
    if (input == null || input <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    double beforeTaxValue;
    double afterTaxValue;

    if (calcMode == 'after') {
      beforeTaxValue = input / (1 + gstRate / 100);
      beforeTaxValue = (beforeTaxValue * 2).round() / 2.0;
      afterTaxValue = input;
    } else {
      beforeTaxValue = input;
      afterTaxValue = input * (1 + gstRate / 100);
      afterTaxValue = (afterTaxValue * 2).round() / 2.0;
    }

    double totalGSTValue = afterTaxValue - beforeTaxValue;
    double halfGST = totalGSTValue / 2;
    halfGST = (halfGST * 2).round() / 2.0;
    cgst = halfGST;
    sgst = halfGST;
    totalGSTValue = cgst! + sgst!;

    setState(() {
      beforeTax = beforeTaxValue;
      afterTax = afterTaxValue;
      totalGST = totalGSTValue;
    });
  }

  void _onModeChanged(String value) {
    setState(() {
      calcMode = value;
      _amountController.clear(); // reset input field
      beforeTax = null;
      afterTax = null;
      totalGST = null;
      cgst = null;
      sgst = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GST Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GST Calculation Mode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'With GST',
                      ),
                      value: 'after',
                      groupValue: calcMode,
                      onChanged: (value) => _onModeChanged(value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'Without GST',
                      ),
                      value: 'before',
                      groupValue: calcMode,
                      onChanged: (value) => _onModeChanged(value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: calcMode == 'after'
                      ? 'e.g. 8400 (With GST)'
                      : 'e.g. 7118.64 (Without GST)',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calculate),
                      onPressed: calculateGST,
                      label: const Text('Calculate'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 25),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16, height: 20),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _amountController.clear();
                        _onModeChanged(
                            calcMode); // Reapply current mode to trigger reset logic
                      },
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 25),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (beforeTax != null) ...[
                const Divider(thickness: 2),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'GST Breakdown',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 20),
                _buildResultRow('Amount Without GST', beforeTax!),
                _buildResultRow('Total GST (18%)', totalGST!),
                _buildResultRow('  CGST (9%)', cgst!),
                _buildResultRow('  SGST (9%)', sgst!),
                const SizedBox(height: 10),
                const Divider(),
                _buildResultRow('Amount With GST', afterTax!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Text('₹ ${_format(amount: value)}',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _format({required double amount}) => amount.toStringAsFixed(2);
}
