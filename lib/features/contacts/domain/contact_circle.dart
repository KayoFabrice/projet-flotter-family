enum ContactCircle {
  proches,
  eloignes,
  partenaire,
  amis,
}

extension ContactCircleMapping on ContactCircle {
  static ContactCircle fromStorage(String value) {
    switch (value) {
      case 'eloignes':
        return ContactCircle.eloignes;
      case 'partenaire':
        return ContactCircle.partenaire;
      case 'amis':
        return ContactCircle.amis;
      case 'proches':
      default:
        return ContactCircle.proches;
    }
  }

  String get storageValue {
    switch (this) {
      case ContactCircle.proches:
        return 'proches';
      case ContactCircle.eloignes:
        return 'eloignes';
      case ContactCircle.partenaire:
        return 'partenaire';
      case ContactCircle.amis:
        return 'amis';
    }
  }

  String get label {
    switch (this) {
      case ContactCircle.proches:
        return 'Parents';
      case ContactCircle.eloignes:
        return 'Freres & Soeurs';
      case ContactCircle.partenaire:
        return 'Grand-parents';
      case ContactCircle.amis:
        return 'Amis proches';
    }
  }
}
