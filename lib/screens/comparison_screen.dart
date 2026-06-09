import 'package:flutter/material.dart';
import 'package:spty_calculadora/models/vehicle.dart';
import 'package:spty_calculadora/services/calculator_service.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({Key? key}) : super(key: key);

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  // Controladores para vehículo eléctrico
  final _evNameController = TextEditingController();
  final _evBatteryController = TextEditingController();
  final _evAutonomyController = TextEditingController();
  final _evElectricityRateController = TextEditingController();
  final _evPriceController = TextEditingController();

  // Controladores para vehículo de combustión
  final _fossilNameController = TextEditingController();
  final _fossilFuelPriceController = TextEditingController();
  final _fossilPriceController = TextEditingController();
  final _monthlyKmController = TextEditingController(text: '1000');

  FuelType _selectedFuelType = FuelType.gasoline;
  ComparisonResult? _comparisonResult;

  @override
  void dispose() {
    _evNameController.dispose();
    _evBatteryController.dispose();
    _evAutonomyController.dispose();
    _evElectricityRateController.dispose();
    _evPriceController.dispose();
    _fossilNameController.dispose();
    _fossilFuelPriceController.dispose();
    _fossilPriceController.dispose();
    _monthlyKmController.dispose();
    super.dispose();
  }

  void _calculateComparison() {
    try {
      final ev = ElectricVehicle(
        name: _evNameController.text.isNotEmpty ? _evNameController.text : 'EV',
        batteryCapacityKwh: double.parse(_evBatteryController.text),
        autonomyKm: double.parse(_evAutonomyController.text),
        electricityRatePerKwh: double.parse(_evElectricityRateController.text),
        purchasePriceUSD: double.parse(_evPriceController.text),
      );

      final fossilFuel = FossilFuelVehicle(
        name: _fossilNameController.text.isNotEmpty
            ? _fossilNameController.text
            : 'Combustión',
        fuelPricePerLiter: double.parse(_fossilFuelPriceController.text),
        purchasePriceUSD: double.parse(_fossilPriceController.text),
        fuelType: _selectedFuelType,
      );

      final monthlyKm = double.parse(_monthlyKmController.text);

      final result = CalculatorService.compareVehicles(
        ev: ev,
        fossilFuel: fossilFuel,
        monthlyKmDriven: monthlyKm,
      );

      setState(() {
        _comparisonResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Completa todos los campos correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparar Vehículos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCIÓN: Vehículo Eléctrico
            _buildSectionTitle('⚡ Vehículo Eléctrico'),
            _buildTextField(_evNameController, 'Nombre (ej: Tesla Model 3)'),
            _buildTextField(
              _evBatteryController,
              'Capacidad batería (kWh)',
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              _evAutonomyController,
              'Autonomía (km)',
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              _evElectricityRateController,
              'Tarifa eléctrica (\$/kWh)',
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              _evPriceController,
              'Precio del vehículo (\$)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // SECCIÓN: Vehículo de Combustión
            _buildSectionTitle('🛢️ Vehículo de Combustión'),
            _buildTextField(_fossilNameController, 'Nombre (ej: Toyota Corolla)'),
            _buildFuelTypeSelector(),
            _buildTextField(
              _fossilFuelPriceController,
              'Precio del combustible (\$/L)',
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              _fossilPriceController,
              'Precio del vehículo (\$)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // SECCIÓN: Parámetros de uso
            _buildSectionTitle('📊 Parámetros de uso'),
            _buildTextField(
              _monthlyKmController,
              'Kilómetros mensuales',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // BOTÓN: Calcular
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculateComparison,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular Comparación'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SECCIÓN: Resultados
            if (_comparisonResult != null) ...[
              _buildSectionTitle('📈 Resultados'),
              _buildComparisonResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildFuelTypeSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<FuelType>(
              segments: const [
                ButtonSegment(label: Text('Gasolina'), value: FuelType.gasoline),
                ButtonSegment(label: Text('Diésel'), value: FuelType.diesel),
              ],
              selected: {_selectedFuelType},
              onSelectionChanged: (Set<FuelType> newSelection) {
                setState(() {
                  _selectedFuelType = newSelection.first;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonResults() {
    final result = _comparisonResult!;
    final paybackYearsMonths = result.paybackMonths != null
        ? CalculatorService.monthsToYearsAndMonths(result.paybackMonths!)
        : null;

    return Column(
      children: [
        // Costo de carga completa
        _buildResultCard(
          title: 'Costo de carga completa (EV)',
          value: '\$${result.evFullChargePrice.toStringAsFixed(2)}',
          color: Colors.blue,
        ),

        // Costo por kilómetro
        _buildResultCard(
          title: 'Costo por km',
          value:
              'EV: \$${result.evCostPerKm.toStringAsFixed(4)} | Combustión: \$${result.fossilCostPerKm.toStringAsFixed(4)}',
          color: Colors.purple,
        ),

        // Costo mensual
        _buildResultCard(
          title: 'Costo operativo mensual',
          value:
              'EV: \$${result.evMonthlyCost.toStringAsFixed(2)} | Combustión: \$${result.fossilMonthlyCost.toStringAsFixed(2)}',
          color: Colors.orange,
        ),

        // Costo anual
        _buildResultCard(
          title: 'Costo operativo anual',
          value:
              'EV: \$${result.evAnnualCost.toStringAsFixed(2)} | Combustión: \$${result.fossilAnnualCost.toStringAsFixed(2)}',
          color: Colors.red,
        ),

        // Ahorro mensual
        _buildResultCard(
          title: 'Ahorro mensual',
          value: '\$${result.monthlySavings.toStringAsFixed(2)}',
          color: Colors.green,
        ),

        // Ahorro anual
        _buildResultCard(
          title: 'Ahorro anual',
          value: '\$${result.annualSavings.toStringAsFixed(2)}',
          color: Colors.green,
        ),

        // Diferencia de inversión
        _buildResultCard(
          title: 'Diferencia de inversión',
          value: '\$${result.investmentDifference.toStringAsFixed(2)}',
          color: Colors.teal,
        ),

        // Tiempo de recuperación
        if (paybackYearsMonths != null)
          _buildResultCard(
            title: 'Tiempo estimado de recuperación',
            value:
                '${paybackYearsMonths.years} años ${paybackYearsMonths.months} meses (${result.paybackMonths} meses)',
            color: Colors.indigo,
          )
        else
          _buildResultCard(
            title: 'Tiempo de recuperación',
            value: 'No hay diferencia o el EV es más caro en operación',
            color: Colors.grey,
          ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
