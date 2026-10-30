import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SettingsApp());
}

class SettingsApp extends StatelessWidget {
  const SettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF5367E8);

    return MaterialApp(
      title: 'Ajustes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          surface: const Color(0xFFF6F7FB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        fontFamily: 'Roboto',
      ),
      home: const SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _categories = [
    _SettingsCategory('General', Icons.tune_rounded),
    _SettingsCategory('Notificaciones', Icons.notifications_none_rounded),
    _SettingsCategory('Privacidad', Icons.shield_outlined),
    _SettingsCategory('Cuenta', Icons.person_outline_rounded),
    _SettingsCategory('Acerca de', Icons.info_outline_rounded),
  ];
  static const _categorySearchTerms = [
    'apariencia tema iniciar reducir animaciones',
    'push resumen semanal sonidos correo',
    'datos analiticas personalizacion verificacion seguridad eliminar',
    'nombre correo plan dispositivos sesion',
    'version ayuda terminos soporte privacidad',
  ];

  final Map<String, bool> _preferences = {
    'notificaciones': true,
    'resumen_semanal': false,
    'sonidos': true,
    'analiticas': false,
    'personalizacion': true,
    'verificacion': true,
    'inicio': false,
    'animaciones': false,
  };

  int _selectedCategory = 0;
  String _appearance = 'Sistema';
  String _displayName = 'Alex Morgan';
  String _email = 'alex.morgan@email.com';

  void _selectCategory(int index) {
    setState(() => _selectedCategory = index);
  }

  void _togglePreference(String key, bool value) {
    setState(() => _preferences[key] = value);
  }

  Future<void> _openSearch() async {
    final selectedCategory = await showDialog<int>(
      context: context,
      builder: (context) => _SettingsSearchDialog(
        categories: _categories,
        descriptions: List.generate(_categories.length, _categoryDescription),
        searchTerms: _categorySearchTerms,
      ),
    );
    if (selectedCategory != null && mounted) {
      _selectCategory(selectedCategory);
    }
  }

  Future<void> _editProfileField({
    required String title,
    required String initialValue,
    required ValueChanged<String> onSave,
  }) async {
    var editedValue = initialValue;
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Editar $title'),
        content: TextField(
          autofocus: true,
          keyboardType: title == 'correo electrónico'
              ? TextInputType.emailAddress
              : TextInputType.name,
          decoration: InputDecoration(labelText: title),
          onChanged: (value) => editedValue = value,
          onSubmitted: (_) => Navigator.pop(dialogContext, editedValue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, editedValue),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    final trimmedValue = value?.trim();
    if (trimmedValue == null || !mounted) return;
    if (trimmedValue.isEmpty ||
        (title == 'correo electrónico' && !trimmedValue.contains('@'))) {
      _showMessage(
        title == 'correo electrónico'
            ? 'Introduce un correo electrónico válido.'
            : 'El nombre no puede estar vacío.',
      );
      return;
    }

    setState(() => onSave(trimmedValue));
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _manageData() async {
    final requestCopy = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gestionar mis datos'),
        content: const Text(
          'Puedes solicitar una copia de tus datos o iniciar su eliminación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Solicitar copia'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Eliminar datos'),
          ),
        ],
      ),
    );
    if (!mounted || requestCopy == null) return;
    if (requestCopy) {
      _showMessage('Solicitud de copia de datos registrada.');
      return;
    }

    final confirmed = await _confirmAction(
      title: 'Solicitar eliminación de datos',
      message: 'Esta acción iniciará una solicitud para eliminar tus datos personales. ¿Quieres continuar?',
      confirmLabel: 'Solicitar',
    );
    if (confirmed && mounted) {
      _showMessage('Solicitud de eliminación registrada.');
    }
  }

  Future<void> _signOut() async {
    final confirmed = await _confirmAction(
      title: 'Cerrar sesión',
      message: '¿Quieres cerrar la sesión de este dispositivo?',
      confirmLabel: 'Cerrar sesión',
    );
    if (confirmed && mounted) _showMessage('Sesión cerrada.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInfoDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 860;
            final content = _buildContent(isWide: isWide);

            if (isWide) {
              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 32,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 244,
                            child: _buildNavigation(isWide: true),
                          ),
                          const SizedBox(width: 48),
                          Expanded(child: content),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMobileHeader(),
                  const SizedBox(height: 22),
                  _buildNavigation(isWide: false),
                  const SizedBox(height: 24),
                  content,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF5367E8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: Color(0xFF5367E8),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Ajustes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        IconButton(
          onPressed: _openSearch,
          tooltip: 'Buscar ajustes',
          icon: const Icon(Icons.search_rounded),
        ),
      ],
    );
  }

  Widget _buildNavigation({required bool isWide}) {
    if (!isWide) {
      return SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final selected = _selectedCategory == index;
            return ChoiceChip(
              avatar: Icon(
                category.icon,
                size: 17,
                color: selected ? Colors.white : const Color(0xFF72788B),
              ),
              label: Text(category.label),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => _selectCategory(index),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF5367E8),
              side: BorderSide(
                color: selected
                    ? const Color(0xFF5367E8)
                    : const Color(0xFFE9EAF0),
              ),
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF555B6D),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            );
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 18),
          child: Text(
            'PREFERENCIAS',
            style: TextStyle(
              color: Color(0xFF9297A7),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (var index = 0; index < _categories.length; index++) ...[
          _NavigationItem(
            category: _categories[index],
            selected: _selectedCategory == index,
            onTap: () => _selectCategory(index),
          ),
          if (index != _categories.length - 1) const SizedBox(height: 6),
        ],
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEDEEF3)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 21,
                backgroundColor: Color(0xFFE9EAFE),
                child: Text(
                  'AM',
                  style: TextStyle(
                    color: Color(0xFF5367E8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Plan personal',
                      style: TextStyle(color: Color(0xFF9297A7), fontSize: 11),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opciones de cuenta',
                onSelected: (action) {
                  switch (action) {
                    case 'profile':
                      _selectCategory(3);
                      break;
                    case 'edit':
                      _editProfileField(
                        title: 'nombre',
                        initialValue: _displayName,
                        onSave: (value) => _displayName = value,
                      );
                      break;
                    case 'sign_out':
                      _signOut();
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'profile', child: Text('Ver cuenta')),
                  PopupMenuItem(value: 'edit', child: Text('Editar nombre')),
                  PopupMenuItem(
                    value: 'sign_out',
                    child: Text('Cerrar sesión'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent({required bool isWide}) {
    final category = _categories[_selectedCategory];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWide) ...[
          Row(
            children: [
              const Text(
                'Ajustes',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF43A982),
                size: 17,
              ),
              const SizedBox(width: 7),
              const Text(
                'Todo está al día',
                style: TextStyle(
                  color: Color(0xFF73798B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 18),
              IconButton(
                onPressed: _openSearch,
                tooltip: 'Buscar ajustes',
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          const SizedBox(height: 34),
        ],
        Text(
          category.label,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _categoryDescription(_selectedCategory),
          style: const TextStyle(color: Color(0xFF818698), fontSize: 14),
        ),
        const SizedBox(height: 24),
        if (_selectedCategory == 0) ..._generalSettings(),
        if (_selectedCategory == 1) ..._notificationSettings(),
        if (_selectedCategory == 2) ..._privacySettings(),
        if (_selectedCategory == 3) ..._accountSettings(),
        if (_selectedCategory == 4) ..._aboutSettings(),
      ],
    );
  }

  List<Widget> _generalSettings() {
    return [
      _buildProfileCard(),
      const SizedBox(height: 20),
      _SettingsCard(
        title: 'Preferencias generales',
        subtitle: 'Personaliza cómo se ve y se comporta la aplicación.',
        children: [
          _buildAppearanceRow(),
          _settingSwitch(
            icon: Icons.rocket_launch_outlined,
            title: 'Iniciar al encender el dispositivo',
            subtitle: 'Abre la aplicación automáticamente.',
            preferenceKey: 'inicio',
          ),
          _settingSwitch(
            icon: Icons.motion_photos_off_outlined,
            title: 'Reducir animaciones',
            subtitle: 'Usa transiciones más sencillas.',
            preferenceKey: 'animaciones',
          ),
        ],
      ),
    ];
  }

  List<Widget> _notificationSettings() {
    return [
      _SettingsCard(
        title: 'Notificaciones',
        subtitle: 'Elige qué avisos quieres recibir y cuándo.',
        children: [
          _settingSwitch(
            icon: Icons.notifications_active_outlined,
            title: 'Notificaciones push',
            subtitle: 'Novedades importantes y actividad de tu cuenta.',
            preferenceKey: 'notificaciones',
          ),
          _settingSwitch(
            icon: Icons.email_outlined,
            title: 'Resumen semanal',
            subtitle: 'Recibe un resumen cada lunes por correo.',
            preferenceKey: 'resumen_semanal',
          ),
          _settingSwitch(
            icon: Icons.volume_up_outlined,
            title: 'Sonidos',
            subtitle: 'Reproduce un sonido al recibir notificaciones.',
            preferenceKey: 'sonidos',
          ),
        ],
      ),
    ];
  }

  List<Widget> _privacySettings() {
    return [
      _SettingsCard(
        title: 'Privacidad y datos',
        subtitle: 'Tú decides cómo se usan tus datos.',
        children: [
          _settingSwitch(
            icon: Icons.insights_outlined,
            title: 'Compartir datos de uso',
            subtitle: 'Ayúdanos a mejorar con datos de diagnóstico anónimos.',
            preferenceKey: 'analiticas',
          ),
          _settingSwitch(
            icon: Icons.auto_awesome_outlined,
            title: 'Contenido personalizado',
            subtitle: 'Recomendaciones basadas en tu actividad.',
            preferenceKey: 'personalizacion',
          ),
          _settingSwitch(
            icon: Icons.verified_user_outlined,
            title: 'Verificación en dos pasos',
            subtitle: 'Añade una capa extra de seguridad a tu cuenta.',
            preferenceKey: 'verificacion',
          ),
          _SettingsActionRow(
            icon: Icons.delete_outline_rounded,
            title: 'Eliminar mis datos',
            subtitle: 'Solicita una copia o elimina tus datos personales.',
            onTap: _manageData,
          ),
        ],
      ),
    ];
  }

  List<Widget> _accountSettings() {
    return [
      _SettingsCard(
        title: 'Información personal',
        subtitle: 'Gestiona los datos asociados a tu perfil.',
        children: [
          _SettingsActionRow(
            icon: Icons.person_outline_rounded,
            title: 'Nombre',
            subtitle: _displayName,
            onTap: () => _editProfileField(
              title: 'nombre',
              initialValue: _displayName,
              onSave: (value) => _displayName = value,
            ),
          ),
          _SettingsActionRow(
            icon: Icons.mail_outline_rounded,
            title: 'Correo electrónico',
            subtitle: _email,
            onTap: () => _editProfileField(
              title: 'correo electrónico',
              initialValue: _email,
              onSave: (value) => _email = value,
            ),
          ),
          _SettingsActionRow(
            icon: Icons.workspace_premium_outlined,
            title: 'Tu plan',
            subtitle: 'Personal · Renovación el 24 de noviembre',
            onTap: () => _showInfoDialog(
              'Plan personal',
              'Tu plan personal está activo. La próxima renovación será el 24 de noviembre.',
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      _SettingsCard(
        title: 'Sesión',
        subtitle: 'Controla el acceso a tu cuenta.',
        children: [
          _SettingsActionRow(
            icon: Icons.devices_outlined,
            title: 'Dispositivos conectados',
            subtitle: '2 dispositivos activos',
            onTap: () => _showInfoDialog(
              'Dispositivos conectados',
              'Este dispositivo y tu portátil tienen una sesión activa.',
            ),
          ),
          _SettingsActionRow(
            icon: Icons.logout_rounded,
            title: 'Cerrar sesión',
            subtitle: 'Sal de tu cuenta en este dispositivo.',
            onTap: _signOut,
          ),
        ],
      ),
    ];
  }

  List<Widget> _aboutSettings() {
    return [
      _SettingsCard(
        title: 'Acerca de esta aplicación',
        subtitle: 'Información y recursos de ayuda.',
        children: [
          _SettingsActionRow(
            icon: Icons.apps_rounded,
            title: 'Versión',
            subtitle: '1.0.0 (última versión)',
            showChevron: false,
            onTap: () => _showInfoDialog(
              'Versión de la aplicación',
              'Estás usando la versión 1.0.0. Tienes la versión más reciente.',
            ),
          ),
          _SettingsActionRow(
            icon: Icons.menu_book_outlined,
            title: 'Centro de ayuda',
            subtitle: 'Encuentra respuestas y consejos.',
            onTap: () => _showInfoDialog(
              'Centro de ayuda',
              'Puedes consultar preguntas frecuentes y contactar con soporte en ayuda@email.com.',
            ),
          ),
          _SettingsActionRow(
            icon: Icons.description_outlined,
            title: 'Términos y privacidad',
            subtitle: 'Consulta nuestras políticas.',
            onTap: () => _showInfoDialog(
              'Términos y privacidad',
              'Tus datos se utilizan de acuerdo con las preferencias de privacidad de tu cuenta.',
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF596DEB), Color(0xFF7886F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          final avatar = Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: const Center(
              child: Text(
                'AM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
          final profileInfo = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _email,
                style: const TextStyle(color: Color(0xFFE4E7FF), fontSize: 12),
              ),
            ],
          );
          final editButton = TextButton(
            onPressed: () => _selectCategory(3),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text('Editar perfil'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    avatar,
                    const SizedBox(width: 15),
                    Expanded(child: profileInfo),
                  ],
                ),
                Align(alignment: Alignment.centerRight, child: editButton),
              ],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 15),
              Expanded(child: profileInfo),
              editButton,
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppearanceRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          const description = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apariencia',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                'Selecciona el tema de la aplicación.',
                style: TextStyle(color: Color(0xFF9297A7), fontSize: 12),
              ),
            ],
          );
          final selector = DropdownButton<String>(
            value: _appearance,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12),
            items: const [
              DropdownMenuItem(value: 'Sistema', child: Text('Sistema')),
              DropdownMenuItem(value: 'Claro', child: Text('Claro')),
              DropdownMenuItem(value: 'Oscuro', child: Text('Oscuro')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _appearance = value);
            },
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _LeadingIcon(icon: Icons.palette_outlined),
                    const SizedBox(width: 14),
                    const Expanded(child: description),
                  ],
                ),
                Align(alignment: Alignment.centerRight, child: selector),
              ],
            );
          }

          return Row(
            children: [
              const _LeadingIcon(icon: Icons.palette_outlined),
              const SizedBox(width: 14),
              const Expanded(child: description),
              selector,
            ],
          );
        },
      ),
    );
  }

  Widget _settingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required String preferenceKey,
  }) {
    return _SettingsSwitchRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      value: _preferences[preferenceKey] ?? false,
      onChanged: (value) => _togglePreference(preferenceKey, value),
    );
  }

  String _categoryDescription(int index) {
    return switch (index) {
      0 => 'Configura tu experiencia para que se adapte a ti.',
      1 => 'Mantente al tanto de lo que más te importa.',
      2 => 'Administra tu seguridad y el uso de tus datos.',
      3 => 'Actualiza tu perfil y administra tu sesión.',
      _ => 'Conoce más sobre la aplicación y encuentra ayuda.',
    };
  }
}

class _SettingsCategory {
  const _SettingsCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _SettingsSearchDialog extends StatefulWidget {
  const _SettingsSearchDialog({
    required this.categories,
    required this.descriptions,
    required this.searchTerms,
  });

  final List<_SettingsCategory> categories;
  final List<String> descriptions;
  final List<String> searchTerms;

  @override
  State<_SettingsSearchDialog> createState() => _SettingsSearchDialogState();
}

class _SettingsSearchDialogState extends State<_SettingsSearchDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final results =
        List<int>.generate(widget.categories.length, (index) => index).where((
          index,
        ) {
          final searchableText =
              '${widget.categories[index].label} '
              '${widget.descriptions[index]} ${widget.searchTerms[index]}';
          return searchableText.toLowerCase().contains(normalizedQuery);
        }).toList();
    final listHeight = (MediaQuery.sizeOf(context).height * 0.3)
        .clamp(100.0, 240.0)
        .toDouble();

    return AlertDialog(
      title: const Text('Buscar ajustes'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Por ejemplo: privacidad',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: listHeight,
              child: results.isEmpty
                  ? const Center(child: Text('No se encontraron ajustes.'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, resultIndex) {
                        final index = results[resultIndex];
                        return ListTile(
                          leading: Icon(widget.categories[index].icon),
                          title: Text(widget.categories[index].label),
                          subtitle: Text(
                            widget.descriptions[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.pop(context, index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _SettingsCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF5367E8).withValues(alpha: 0.1) : null,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Icon(
                category.icon,
                size: 19,
                color: selected
                    ? const Color(0xFF5367E8)
                    : const Color(0xFF858A9B),
              ),
              const SizedBox(width: 12),
              Text(
                category.label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF5367E8)
                      : const Color(0xFF555B6D),
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEEF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080E1530),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 19, 20, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9297A7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, color: Color(0xFFF0F1F5)),
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final switchControl = !kIsWeb && Platform.isIOS
        ? CupertinoSwitch(value: value, onChanged: onChanged)
        : Switch(value: value, onChanged: onChanged);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          final settingTitle = Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          );
          final settingSubtitle = Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF9297A7), fontSize: 11),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _LeadingIcon(icon: icon),
                    const SizedBox(width: 14),
                    Expanded(child: settingTitle),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50, top: 8),
                  child: Row(
                    children: [
                      Expanded(child: settingSubtitle),
                      switchControl,
                    ],
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              _LeadingIcon(icon: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    settingTitle,
                    const SizedBox(height: 4),
                    settingSubtitle,
                  ],
                ),
              ),
              const SizedBox(width: 10),
              switchControl,
            ],
          );
        },
      ),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            _LeadingIcon(icon: icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9297A7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB4B8C5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF73798B)),
    );
  }
}
