class GlobalCadenceOption {
  const GlobalCadenceOption({required this.key, required this.label});

  final String key;
  final String label;

  static const options = <GlobalCadenceOption>[
    GlobalCadenceOption(key: 'quotidien', label: 'Quotidien'),
    GlobalCadenceOption(key: 'hebdomadaire', label: 'Hebdomadaire'),
    GlobalCadenceOption(key: 'bi_mensuel', label: 'Bi-mensuel'),
    GlobalCadenceOption(key: 'mensuel', label: 'Mensuel'),
    GlobalCadenceOption(key: 'trimestriel', label: 'Trimestriel'),
  ];
}

class GlobalCadenceState {
  const GlobalCadenceState({required this.options, required this.selectedKey});

  final List<GlobalCadenceOption> options;
  final String selectedKey;

  GlobalCadenceState select(String key) {
    return GlobalCadenceState(options: options, selectedKey: key);
  }
}
