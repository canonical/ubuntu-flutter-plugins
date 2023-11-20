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
    expect(() => getService<Service>(), throwsStateError);
    expect(tryGetService<Service>(), isNull);
  });

  test('locate service', () {
    registerService(Service.new);
    expect(getService<Service>(), isNotNull);
    expect(tryGetService<Service>(), isNotNull);
  });

  test('locate service instance', () {
    final service = Service();
    registerServiceInstance(service);
    expect(getService<Service>(), equals(service));
    expect(tryGetService<Service>(), equals(service));
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

  test('reset all services', () async {
    Service? wasDisposed1, wasDisposed2, wasDisposed3;
    registerService<Service>(Service.new, dispose: (s) => wasDisposed1 = s);
    registerService<Service2>(Service2.new, dispose: (s) => wasDisposed2 = s);
    registerService<Service3>(Service3.new, dispose: (s) => wasDisposed3 = s);

    final s1 = getService<Service>();
    final s2 = getService<Service2>();
    final s3 = getService<Service3>();

    await resetAllServices();

    expect(wasDisposed1, s1);
    expect(wasDisposed2, s2);
    expect(wasDisposed3, s3);
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

    expect(() => getService<Service>(), throwsStateError);
    expect(getService<Service>(id: '2'), isA<Service2>());
    expect(getService<Service>(id: '3'), isA<Service3>());

    unregisterService<Service>(id: '2');

    expect(() => getService<Service>(), throwsStateError);
    expect(() => getService<Service>(id: '2'), throwsStateError);
    expect(getService<Service>(id: '3'), isA<Service3>());

    unregisterService<Service>(id: '3');

    expect(() => getService<Service>(), throwsStateError);
    expect(() => getService<Service>(id: '2'), throwsStateError);
    expect(() => getService<Service>(id: '3'), throwsStateError);
  });

  test('service factory', () {
    final s0 = tryCreateService<ServiceParam, String>('p0');
    expect(s0, isNull);

    registerServiceFactory<ServiceParam, String>(ServiceParam.new);

    final s1 = createService<ServiceParam, String>('p1');
    expect(s1, isA<ServiceParam>().having((s) => s.param, 'param', 'p1'));

    final s2 = createService<ServiceParam, String>('p2');
    expect(s2, isA<ServiceParam>().having((s) => s.param, 'param', 'p2'));
  });

  test('try register', () {
    expect(hasService<Service>(), isFalse);

    tryRegisterService(Service.new);
    expect(hasService<Service>(), isTrue);

    final s1 = getService<Service>();
    tryRegisterService(Service.new); // noop

    final s2 = getService<Service>();
    expect(s2, same(s1));
  });

  test('try instance', () {
    expect(hasService<Service>(), isFalse);

    final s1 = Service();
    tryRegisterServiceInstance(s1);
    expect(hasService<Service>(), isTrue);

    final s2 = Service();
    tryRegisterServiceInstance(s2); // noop
    expect(getService<Service>(), same(s1));
  });

  test('try factory', () {
    expect(hasService<Service>(), isFalse);

    tryRegisterServiceFactory<ServiceParam, String>(ServiceParam.new);
    expect(hasService<ServiceParam>(), isTrue);

    final s1 = createService<ServiceParam, String>('p1');
    expect(s1, isA<ServiceParam>().having((s) => s.param, 'param', 'p1'));

    // noop
    tryRegisterServiceFactory<ServiceParam, String>(
      (param) => ServiceParam('${param}2'),
    );

    final s2 = createService<ServiceParam, String>('p2');
    expect(s2, isA<ServiceParam>().having((s) => s.param, 'param', 'p2'));
  });
}
