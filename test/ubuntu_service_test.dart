import 'package:test/test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class Service extends Object {}

class Service2 extends Service {}

class Service3 extends Service {}

void main() {
  tearDown(() => unregisterMockService<Service>());

  test('unknown service', () {
    expect(() => getService<Service>(), throwsA(isA<AssertionError>()));
  });

  test('re-register service', () {
    expect(() => registerService(Service.new), isNot(throwsA(anything)));
    // re-registration required in integration tests
    expect(() => registerService(Service.new), isNot(throwsA(anything)));
  });

  test('re-register service instance', () {
    final service = Service();
    expect(() => registerServiceInstance(service), isNot(throwsA(anything)));
    // re-registration required in integration tests
    expect(() => registerServiceInstance(service), isNot(throwsA(anything)));
  });

  test('locate service', () {
    registerService(Service.new);
    expect(getService<Service>(), isNotNull);
  });

  test('locate service instance', () {
    final service = Service();
    registerServiceInstance(service);
    expect(getService<Service>(), equals(service));
  });

  test('mock service', () {
    final mock1 = Service();
    final mock2 = Service();
    expect(mock1, isNot(equals(mock2)));

    registerMockService(mock1);
    expect(getService<Service>(), equals(mock1));

    registerMockService(mock2);
    expect(getService<Service>(), equals(mock2));
  });

  test('service id', () {
    registerService<Service>(Service.new);
    registerService<Service>(Service2.new, id: '2');
    registerServiceInstance<Service>(Service3(), id: '3');

    expect(getService<Service>(), isA<Service>());
    expect(getService<Service>(id: '2'), isA<Service2>());
    expect(getService<Service>(id: '3'), isA<Service3>());
  });

  test('unregister service', () {
    registerService<Service>(Service.new);
    registerService<Service>(Service2.new, id: '2');
    registerServiceInstance<Service>(Service3(), id: '3');

    expect(getService<Service>(), isA<Service>());
    expect(getService<Service>(id: '2'), isA<Service2>());
    expect(getService<Service>(id: '3'), isA<Service3>());

    unregisterService<Service>();

    expect(() => getService<Service>(), throwsA(isA<AssertionError>()));
    expect(getService<Service>(id: '2'), isA<Service2>());
    expect(getService<Service>(id: '3'), isA<Service3>());

    unregisterService<Service>(id: '2');

    expect(() => getService<Service>(), throwsA(isA<AssertionError>()));
    expect(() => getService<Service>(id: '2'), throwsA(isA<AssertionError>()));
    expect(getService<Service>(id: '3'), isA<Service3>());

    unregisterService<Service>(id: '3');

    expect(() => getService<Service>(), throwsA(isA<AssertionError>()));
    expect(() => getService<Service>(id: '2'), throwsA(isA<AssertionError>()));
    expect(() => getService<Service>(id: '3'), throwsA(isA<AssertionError>()));
  });
}
