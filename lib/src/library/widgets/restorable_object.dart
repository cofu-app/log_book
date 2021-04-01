import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class RestorableObject implements Listenable {
  Object? restorationData();
  void restore(Object? data);
}

class RestorableObjectBinding<T extends RestorableObject>
    extends RestorableListenable<T> {
  RestorableObjectBinding(this.object);

  final T object;

  @override
  T createDefaultValue() => object;

  @override
  T fromPrimitives(Object? data) => object..restore(data);

  @override
  Object? toPrimitives() => object.restorationData();
}

class RestorableObjectRegistration extends StatefulWidget {
  const RestorableObjectRegistration({
    Key? key,
    required this.object,
    this.restorationId,
    required this.child,
  }) : super(key: key);

  final RestorableObject object;

  final String? restorationId;

  final Widget child;

  @override
  _RestorableObjectRegistrationState createState() =>
      _RestorableObjectRegistrationState();
}

class _RestorableObjectRegistrationState
    extends State<RestorableObjectRegistration> with RestorationMixin {
  late final RestorableObjectBinding _binding;

  @override
  void initState() {
    super.initState();
    _setupBinding();
  }

  @override
  void didUpdateWidget(covariant RestorableObjectRegistration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.object != widget.object) {
      _setupBinding();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_binding, 'restorableObject');
  }

  void _setupBinding() {
    _binding = RestorableObjectBinding(widget.object);
  }
}
