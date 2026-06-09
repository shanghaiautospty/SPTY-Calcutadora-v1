import 'package:spty_calculadora/models/vehicle.dart';

/// Servicio para realizar los cálculos de comparación entre vehículos
class CalculatorService {
  /// Calcula el costo mensual de operación
  static double calculateMonthlyCost(double costPerKm, double km) {
    return costPerKm * km;
  }

  /// Calcula el costo anual de operación
  static double calculateAnnualCost(double monthlyCost) {
    return monthlyCost * 12;
  }

  /// Calcula el ahorro mensual
  static double calculateMonthlySavings(
    double evMonthlyCost,
    double fuelMonthlyCost,
  ) {
    return (fuelMonthlyCost - evMonthlyCost).abs();
  }

  /// Calcula el ahorro anual
  static double calculateAnnualSavings(double monthlySavings) {
    return monthlySavings * 12;
  }

  /// Calcula la diferencia de inversión
  static double calculateInvestmentDifference(
    double evPrice,
    double fuelPrice,
  ) {
    return (evPrice - fuelPrice).abs();
  }

  /// Calcula el tiempo estimado para recuperar la inversión en meses
  static int? calculatePaybackMonths(
    double monthlyEVCost,
    double monthlyFuelCost,
    double investmentDifference,
  ) {
    double monthlyMonthlySavings = (monthlyFuelCost - monthlyEVCost).abs();

    if (monthlyMonthlySavings <= 0) {
      return null; // No hay ahorro
    }

    return (investmentDifference / monthlyMonthlySavings).ceil();
  }

  /// Convierte meses a años y meses
  static ({int years, int months}) monthsToYearsAndMonths(int totalMonths) {
    return (years: totalMonths ~/ 12, months: totalMonths % 12);
  }

  /// Realiza la comparación completa entre dos vehículos
  static ComparisonResult compareVehicles({
    required ElectricVehicle ev,
    required FossilFuelVehicle fossilFuel,
    required double monthlyKmDriven,
  }) {
    final evCostPerKm = ev.getCostPerKm();
    final fossilCostPerKm = fossilFuel.getCostPerKm();

    final evMonthlyCost = calculateMonthlyCost(evCostPerKm, monthlyKmDriven);
    final fossilMonthlyCost =
        calculateMonthlyCost(fossilCostPerKm, monthlyKmDriven);

    final investmentDiff = calculateInvestmentDifference(
      ev.purchasePriceUSD,
      fossilFuel.purchasePriceUSD,
    );

    final paybackMonths = calculatePaybackMonths(
      evMonthlyCost,
      fossilMonthlyCost,
      investmentDiff,
    );

    return ComparisonResult(
      evFullChargePrice: ev.getFullChargePrice(),
      evCostPerKm: evCostPerKm,
      evMonthlyCost: evMonthlyCost,
      evAnnualCost: calculateAnnualCost(evMonthlyCost),
      fossilCostPerKm: fossilCostPerKm,
      fossilMonthlyCost: fossilMonthlyCost,
      fossilAnnualCost: calculateAnnualCost(fossilMonthlyCost),
      monthlySavings: calculateMonthlySavings(evMonthlyCost, fossilMonthlyCost),
      annualSavings:
          calculateAnnualSavings(calculateMonthlySavings(evMonthlyCost, fossilMonthlyCost)),
      investmentDifference: investmentDiff,
      paybackMonths: paybackMonths,
    );
  }
}

/// Resultado de la comparación entre vehículos
class ComparisonResult {
  final double evFullChargePrice;
  final double evCostPerKm;
  final double evMonthlyCost;
  final double evAnnualCost;
  final double fossilCostPerKm;
  final double fossilMonthlyCost;
  final double fossilAnnualCost;
  final double monthlySavings;
  final double annualSavings;
  final double investmentDifference;
  final int? paybackMonths;

  ComparisonResult({
    required this.evFullChargePrice,
    required this.evCostPerKm,
    required this.evMonthlyCost,
    required this.evAnnualCost,
    required this.fossilCostPerKm,
    required this.fossilMonthlyCost,
    required this.fossilAnnualCost,
    required this.monthlySavings,
    required this.annualSavings,
    required this.investmentDifference,
    required this.paybackMonths,
  });
}