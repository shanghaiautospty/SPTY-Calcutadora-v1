void main() {
  test('calculateMonthlyCost calcula correctamente', () {
    const costPerKm = 0.1;
    const km = 1000.0;
    const expected = 100.0;
    
    expect(CalculatorService.calculateMonthlyCost(costPerKm, km), expected);
  });

  test('calculateAnnualCost multiplica por 12', () {
    const monthlyCost = 100.0;
    const expected = 1200.0;
    
    expect(CalculatorService.calculateAnnualCost(monthlyCost), expected);
  });

  test('ElectricVehicle.getFullChargePrice incluye 10% de pérdidas', () {
    const ev = ElectricVehicle(
      name: 'Test EV',
      batteryCapacityKwh: 100,
      autonomyKm: 500,
      electricityRatePerKwh: 0.10,
      purchasePriceUSD: 50000,
    );

    final expected = 100 * 0.10 * 1.10; // 11.0
    expect(ev.getFullChargePrice(), expected);
  });

  test('FossilFuelVehicle gasoline tiene consumo de 8 L/100km', () {
    const vehicle = FossilFuelVehicle(
      name: 'Test Gasoline',
      fuelPricePerLiter: 1.0,
      purchasePriceUSD: 25000,
      fuelType: FuelType.gasoline,
    );

    expect(vehicle.getConsumptionPer100km(), 8.0);
  });

  test('FossilFuelVehicle diesel tiene consumo de 6 L/100km', () {
    const vehicle = FossilFuelVehicle(
      name: 'Test Diesel',
      fuelPricePerLiter: 1.0,
      purchasePriceUSD: 25000,
      fuelType: FuelType.diesel,
    );

    expect(vehicle.getConsumptionPer100km(), 6.0);
  });
}
