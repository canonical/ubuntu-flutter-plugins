import 'package:test/test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class Service extends Object {}

class Service2 extends Service {}

class Service3 extends Service {}

class ServiceParam extends Service {
  ServiceParam(this.param);
  final String param;
}

void main() {
  tearDown(() => unregisterMockService<Service>());

  test('unknown service', () {
    expect(() => getService<Service>(), throwsA(isA<AssertionError>()));
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

  test('reset service', () {
    Service? wasDisposed1, wasDisposed2;
    registerService<Service>(Service.new, dispose: (s) => wasDisposed1 = s);

    final s1 = getService<Service>();
    expect(s1, same(getService<Service>()));
    resetService<Service>();
    expect(wasDisposed1, s1);

    final s2 = getService<Service>();
    expect(s2, same(getService<Service>()));
    expect(s2, isNot(same(s1)));
    resetService<Service>(dispose: (s) => wasDisposed2 = s);
    expect(wasDisposed2, s2);
    expect(wasDisposed1, s1);
  });

  test('mock service', () {
    final mock1 = Service();
    final mock2 = Service();
    expect(mock1, isNot(equals(mock2)));

    registerMockService(mock1);
    expect(getService<Service>(), equals(mock1));

    unregisterMockService<Service>();

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

  test('service factory', () {
    registerServiceFactory<ServiceParam>(
      (dynamic param) => ServiceParam(param as String),
    );

    final s1 = createService<ServiceParam>('p1');
    expect(s1, isA<ServiceParam>().having((s) => s.param, 'param', 'p1'));

    final s2 = createService<ServiceParam>('p2');
    expect(s2, isA<ServiceParam>().having((s) => s.param, 'param', 'p2'));
  });
}
