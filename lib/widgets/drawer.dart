import 'package:app/pages/biblioteca/biblioteca_page.dart';
import 'package:app/pages/disciplina_page.dart';
import 'package:app/pages/documentos/documents_page.dart';
import 'package:app/pages/financeiro/financeiro_page.dart';
import 'package:app/pages/home_page_aluno.dart';
import 'package:app/pages/laboratorios/laboratorios_page.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/pages/notas_page.dart';
import 'package:app/pages/secretaria/secretaria_page.dart';
import 'package:app/pages/solicitacoes/solicitacoes_page.dart';
import 'package:app/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) onItemTap;
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;

  const CustomDrawer({
    Key? key,
    required this.onItemTap,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<bool> _showLogoutConfirmation(BuildContext context) async {
      return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirmar Logout'),
                content: Text('Você deseja sair da sua conta?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Sair'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              );
            },
          ) ??
          false;
    }

    Route _createFadeRoute() {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final fadeAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
      );
    }

    Future<void> _logout(BuildContext context) async {
      bool confirmLogout = await _showLogoutConfirmation(context);

      if (confirmLogout) {
        await clearToken();

        Navigator.of(context).pushReplacement(_createFadeRoute());
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double drawerWidth =
            constraints.maxWidth < 800 ? constraints.maxWidth * 0.7 : 300;

        return ClipRRect(
          borderRadius: const BorderRadius.only(topRight: Radius.circular(16)),
          child: Drawer(
            width: drawerWidth,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  color: Colors.blue,
                  height: constraints.maxHeight * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          fotoAluno ?? 'https://example.com/default_image.png',
                        ),
                        radius: constraints.maxWidth < 800 ? 50 : 60,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        nomeAluno,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: constraints.maxWidth < 800 ? 16 : 18,
                        ),
                      ),
                      Text(
                        'Matrícula: $idMatricula',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: constraints.maxWidth < 800 ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildListTile(
                  context,
                  icon: FontAwesomeIcons.home,
                  title: 'Inicio',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HomePageAluno(
                        nomeAluno: nomeAluno,
                        idMatricula: idMatricula,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                _buildListTile(
                  context,
                  icon: FontAwesomeIcons.dollar,
                  title: 'Financeiro',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FinanceiroPage(
                        nomeAluno: nomeAluno,
                        idMatricula: idMatricula,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                _buildListTile(
                  context,
                  icon: Icons.account_circle,
                  title: 'Minhas Notas',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NotasPage(
                        nomeAluno: nomeAluno,
                        idMatricula: idMatricula,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                _buildListTile(
                  context,
                  icon: Icons.settings,
                  title: 'Disciplinas',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DisciplinaPage(
                        nomeAluno: nomeAluno,
                        idMatricula: idMatricula,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                _buildListTile(
                  context,
                  icon: Icons.settings,
                  title: 'Laboratorios',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LaboratoriosPage(
                        nomeAluno: nomeAluno,
                        idMatricula: idMatricula,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                _buildListTile(
                  context,
                  icon: FontAwesomeIcons.book,
                  title: 'Bibliotecas',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BibliotecaPage(
                        nomeAluno: nomeAluno,
                        idMatricula: idMatricula,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                _buildListTile(
                  context,
                  icon: FontAwesomeIcons.folder,
                  title: 'Documentos',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DocumentsPage(
                        nomeAluno: nomeAluno,
                        idMatricula: idMatricula,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                _buildListTile(
                  context,
                  icon: FontAwesomeIcons.solidClipboard,
                  title: 'Secretaria',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SecretariaPage(
                        nomeAluno: nomeAluno,
                        idMatricula: idMatricula,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                _buildListTile(
                  context,
                  icon: FontAwesomeIcons.dochub,
                  title: 'Solicitações',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SolicitacoesPage(
                        nomeAluno: nomeAluno,
                        idMatricula: idMatricula,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                _buildListTile(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    onItemTap('Settings');
                  },
                ),
                const Divider(
                  height: 1,
                ),
                _buildListTile(
                  context,
                  icon: FontAwesomeIcons.signInAlt,
                  title: 'Sair',
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(
        FontAwesomeIcons.angleRight,
        size: 14,
      ),
      onTap: onTap,
    );
  }
}
