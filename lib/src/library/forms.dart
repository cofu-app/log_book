import 'package:flutter/material.dart';

import 'lang.dart';

FormFieldValidator<String> requiredString() => (value) {
      if (value != null && !value.isBlank) return null;
      return 'This field is required';
    };
