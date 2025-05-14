import 'package:flutter/foundation.dart';

/// Placeholder for ResourceContents if not defined elsewhere.
/// Replace with actual definition if available.
@immutable
class ResourceContents {
  final String placeholder; // Example field
  const ResourceContents({this.placeholder = "resource_placeholder"});
  factory ResourceContents.fromJson(Map<String, dynamic> json) {
    return ResourceContents(
      placeholder: json['placeholder'] ?? "resource_placeholder",
    );
  }
  Map<String, dynamic> toJson() => {'placeholder': placeholder};
}