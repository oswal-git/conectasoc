import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String lastname;
  final String email;
  final String? phone;
  final String language;
  final String? imageUrl;

  const User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    this.phone,
    required this.language,
    this.imageUrl,
  });

  User copyWith({
    String? id,
    String? name,
    String? lastname,
    String? email,
    String? phone,
    String? language,
    String? imageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, lastname, email, phone, language, imageUrl];
}
