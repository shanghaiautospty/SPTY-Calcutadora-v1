import 'package:flutter/material.dart';
import 'package:spty_calculadora/services/calculator_service.dart';

class SavingsSummaryWidget extends StatelessWidget {
  final ComparisonResult result;
  final String evName;
  final String fossilName;

  const SavingsSummaryWidget({
    Key? key,
    required this.result,
    required this.evName,
    required this.fossilName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paybackYearsMonths = result.paybackMonths != null
        ? CalculatorService.monthsToYearsAndMonths(result.paybackMonths!)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text(
            'Resumen de Ahorros',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Comparación de costos mensuales
          _buildComparisonCard(
            title: 'Costo Mensual de Operación',
            evCost: result.evMonthlyCost,
            fossilCost: result.fossilMonthlyCost,
            unit: 'mes',
          ),
          const SizedBox(height: 16),

          // Comparación de costos anuales
          _buildComparisonCard(
            title: 'Costo Anual de Operación',
            evCost: result.evAnnualCost,
            fossilCost: result.fossilAnnualCost,
            unit: 'año',
          ),
          const SizedBox(height: 24),

          // Destacado: Ahorro mensual
          _buildHighlightCard(
            icon: Icons.trending_down,
            title: 'Ahorro Mensual',
            amount: result.monthlySavings,
            color: Colors.green,
          ),
          const SizedBox(height: 12),

          // Destacado: Ahorro anual
          _buildHighlightCard(
            icon: Icons.savings,
            title: 'Ahorro Anual',
            amount: result.annualSavings,
            color: Colors.green,
          ),
          const SizedBox(height: 24),

          // Recuperación de inversión
          if (paybackYearsMonths != null)
            _buildPaybackCard(
              years: paybackYearsMonths.years,
              months: paybackYearsMonths.months,
              totalMonths: result.paybackMonths!,
              investmentDifference: result.investmentDifference,
            )
          else
            _buildNoPaybackCard(),

          const SizedBox(height: 24),

          // Tabla comparativa
          _buildComparisonTable(),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required double evCost,
    required double fossilCost,
    required String unit,
  }) {
    final savings = fossilCost - evCost;
    final isSavings = savings > 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCostBubble(
                    label: evName,
                    cost: evCost,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildCostBubble(
                    label: fossilName,
                    cost: fossilCost,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSavings ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSavings ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isSavings ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSavings
                        ? 'Ahorras \$${savings.toStringAsFixed(2)} por $unit'
                        : 'Cuesta \$${savings.abs().toStringAsFixed(2)} más por $unit',
                    style: TextStyle(
                      color: isSavings ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostBubble({
    required String label,
    required double cost,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${cost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required String title,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaybackCard({
    required int years,
    required int months,
    required int totalMonths,
    required double investmentDifference,
  }) {
    return Card(
      elevation: 4,
      color: Colors.indigo.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recuperación de Inversión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPaybackMetric(
                  label: 'Inversión Extra',
                  value: '\$${investmentDifference.toStringAsFixed(2)}',
                  color: Colors.orange,
                ),
                _buildPaybackMetric(
                  label: 'Recuperación',
                  value: '$years años\n$months meses',
                  color: Colors.indigo,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Recuperarás tu inversión en $totalMonths meses',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaybackMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNoPaybackCard() {
    return Card(
      elevation: 4,
      color: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.info, color: Colors.grey, size: 32),
            const SizedBox(height: 12),
            const Text(
              'No hay diferencia significativa en costos de operación',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'El vehículo eléctrico tiene costos operativos similares o mayores',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparativa Detallada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  children: [
                    _buildTableCell('Concepto', isHeader: true),
                    _buildTableCell(evName, isHeader: true),
                    _buildTableCell(fossilName, isHeader: true),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Costo/km'),
                    _buildTableCell('\$${result.evCostPerKm.toStringAsFixed(4)}'),
                    _buildTableCell('\$${result.fossilCostPerKm.toStringAsFixed(4)}'),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Costo mensual'),
                    _buildTableCell('\$${result.evMonthlyCost.toStringAsFixed(2)}'),
                    _buildTableCell('\$${result.fossilMonthlyCost.toStringAsFixed(2)}'),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Costo anual'),
                    _buildTableCell('\$${result.evAnnualCost.toStringAsFixed(2)}'),
                    _buildTableCell('\$${result.fossilAnnualCost.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
