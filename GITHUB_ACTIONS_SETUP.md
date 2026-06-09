# 🚀 SPTY Calculadora - Configuración CI/CD Manual

Debido a limitaciones de permisos, aquí está la guía para completar manualmente la configuración de GitHub Actions y tests.

## 📋 Archivos que debes crear

### 1. `.github/workflows/flutter_build.yml`

Crea esta carpeta y archivo en la raíz del proyecto:

```yaml
name: Flutter Build & Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run analysis
        run: flutter analyze

      - name: Format check
        run: dart format --set-exit-if-changed lib/ test/

      - name: Run tests
        run: flutter test

      - name: Build APK
        run: flutter build apk --release

      - name: Build Web
        run: flutter build web --release

      - name: Upload APK artifact
        if: success()
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-app.apk

      - name: Upload Web artifact
        if: success()
        uses: actions/upload-artifact@v3
        with:
          name: web-build
          path: build/web
```

### 2. `.github/workflows/code_quality.yml`

```yaml
name: Code Quality

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  quality:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Lint analysis
        run: flutter analyze --no-fatal-infos

      - name: Code format check
        run: dart format --set-exit-if-changed lib/

      - name: Check for unused imports
        run: dart fix --dry-run lib/

  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run unit tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          flags: flutter
```

### 3. `test/calculator_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:spty_calculadora/models/vehicle.dart';
import 'package:spty_calculadora/services/calculator_service.dart';

void main() {
  group('CalculatorService', () {
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

    test('calculateMonthlySavings calcula la diferencia correctamente', () {
      const evCost = 100.0;
      const fossilCost = 150.0;
      const expected = 50.0;

      expect(CalculatorService.calculateMonthlySavings(evCost, fossilCost),
          expected);
    });

    test('calculateAnnualSavings multiplica ahorros mensuales por 12', () {
      const monthlySavings = 50.0;
      const expected = 600.0;

      expect(
          CalculatorService.calculateAnnualSavings(monthlySavings), expected);
    });

    test('calculateInvestmentDifference calcula diferencia de precio', () {
      const evPrice = 50000.0;
      const fossilPrice = 25000.0;
      const expected = 25000.0;

      expect(
          CalculatorService.calculateInvestmentDifference(evPrice, fossilPrice),
          expected);
    });

    test('calculatePaybackMonths calcula meses de recuperacion', () {
      final result =
          CalculatorService.calculatePaybackMonths(100, 200, 5000);

      expect(result, 50);
    });

    test('calculatePaybackMonths retorna null si no hay ahorros', () {
      final result =
          CalculatorService.calculatePaybackMonths(100, 100, 5000);

      expect(result, null);
    });

    test('monthsToYearsAndMonths convierte correctamente', () {
      final result = CalculatorService.monthsToYearsAndMonths(68);

      expect(result.years, 5);
      expect(result.months, 8);
    });
  });

  group('ElectricVehicle', () {
    test('getFullChargePrice incluye 10% de perdidas', () {
      const ev = ElectricVehicle(
        name: 'Tesla Model 3',
        batteryCapacityKwh: 100.0,
        autonomyKm: 500.0,
        electricityRatePerKwh: 0.10,
        purchasePriceUSD: 50000.0,
      );

      final expected = 100 * 0.10 * 1.10;
      expect(ev.getFullChargePrice(), expected);
    });

    test('getCostPerKm calcula correctamente', () {
      const ev = ElectricVehicle(
        name: 'Tesla Model 3',
        batteryCapacityKwh: 100.0,
        autonomyKm: 500.0,
        electricityRatePerKwh: 0.10,
        purchasePriceUSD: 50000.0,
      );

      final fullChargePrice = 100 * 0.10 * 1.10;
      final expected = fullChargePrice / 500.0;
      expect(ev.getCostPerKm(), expected);
    });
  });

  group('FossilFuelVehicle', () {
    test('gasoline tiene consumo de 8 L/100km', () {
      const vehicle = FossilFuelVehicle(
        name: 'Toyota Corolla',
        fuelPricePerLiter: 1.50,
        purchasePriceUSD: 25000.0,
        fuelType: FuelType.gasoline,
      );

      expect(vehicle.getConsumptionPer100km(), 8.0);
    });

    test('diesel tiene consumo de 6 L/100km', () {
      const vehicle = FossilFuelVehicle(
        name: 'Toyota Corolla Diesel',
        fuelPricePerLiter: 1.40,
        purchasePriceUSD: 25000.0,
        fuelType: FuelType.diesel,
      );

      expect(vehicle.getConsumptionPer100km(), 6.0);
    });

    test('getCostPerKm calcula correctamente para gasolina', () {
      const vehicle = FossilFuelVehicle(
        name: 'Toyota Corolla',
        fuelPricePerLiter: 1.50,
        purchasePriceUSD: 25000.0,
        fuelType: FuelType.gasoline,
      );

      final expected = (1.50 * 8.0) / 100;
      expect(vehicle.getCostPerKm(), expected);
    });
  });
}
```

## 🎯 Resumen de lo que ya está listo

✅ **Código Flutter completamente funcional:**
- lib/main.dart - Pantalla principal
- lib/screens/comparison_screen.dart - Pantalla de comparación
- lib/screens/savings_summary_screen.dart - Resumen de ahorros
- lib/models/vehicle.dart - Modelos
- lib/services/calculator_service.dart - Servicios
- pubspec.yaml - Configuración

✅ **GitHub Issues creados:**
- #1: Estructura base
- #2: Vistas y lógica
- #3: Resumen visual

## 📊 Próximos pasos

1. Agrega los archivos de workflows manualmente
2. Crea el archivo test/calculator_service_test.dart
3. Haz push a GitHub
4. Los workflows se ejecutarán automáticamente

## 🚀 Ejecución local

```bash
# Instalar dependencias
flutter pub get

# Ejecutar tests
flutter test

# Análisis de código
flutter analyze

# Ejecutar la app
flutter run
```

---

¿Necesitas ayuda con algo más?
