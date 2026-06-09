/// Modelo para representar datos de un vehículo eléctrico
class ElectricVehicle {
  final String name;
  final double batteryCapacityKwh;
  final double autonomyKm;
  final double electricityRatePerKwh;
  final double purchasePriceUSD;

  const ElectricVehicle({
    required this.name,
    required this.batteryCapacityKwh,
    required this.autonomyKm,
    required this.electricityRatePerKwh,
    required this.purchasePriceUSD,
  });

  /// Calcula el costo de una carga completa
  /// Incluye 10% de pérdidas
  double getFullChargePrice() {
    return batteryCapacityKwh * electricityRatePerKwh * 1.10;
  }

  /// Calcula el costo por kilómetro
  double getCostPerKm() {
    return getFullChargePrice() / autonomyKm;
  }
}

/// Modelo para representar datos de un vehículo de combustión
class FossilFuelVehicle {
  final String name;
  final double fuelPricePerLiter;
  final double purchasePriceUSD;
  final FuelType fuelType;

  const FossilFuelVehicle({
    required this.name,
    required this.fuelPricePerLiter,
    required this.purchasePriceUSD,
    required this.fuelType,
  });

  /// Consumo de referencia en L/100km según tipo de combustible
  double getConsumptionPer100km() {
    return fuelType == FuelType.gasoline ? 8.0 : 6.0;
  }

  /// Calcula el costo por kilómetro
  double getCostPerKm() {
    return (fuelPricePerLiter * getConsumptionPer100km()) / 100;
  }
}

enum FuelType { gasoline, diesel }