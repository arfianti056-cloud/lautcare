class Akun {
  final String nama;
  final String email;
  final String password;

  Akun({required this.nama, required this.email, required this.password});
}

class AkunStore {
  static final List<Akun> _daftarAkun = [];

  static bool daftar({
    required String nama,
    required String email,
    required String password,
  }) {
    final identitas = email.trim().toLowerCase();

    final sudahAda = _daftarAkun.any(
      (akun) => akun.email.toLowerCase() == identitas,
    );

    if (sudahAda) {
      return false;
    }

    _daftarAkun.add(
      Akun(nama: nama.trim(), email: identitas, password: password),
    );

    return true;
  }

  static Akun? login({required String email, required String password}) {
    for (final akun in _daftarAkun) {
      if (akun.email.toLowerCase() == email.trim().toLowerCase() &&
          akun.password == password) {
        return akun;
      }
    }

    return null;
  }
}
