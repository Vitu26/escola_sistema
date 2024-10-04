import 'dart:convert';
import 'package:app/pages/home_page_aluno.dart';
import 'package:app/utils/cache_manager.dart';
import 'package:app/utils/token.dart';
import 'package:app/widgets/custom_buttom.dart';
import 'package:app/widgets/textfield_custom.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController =
      TextEditingController(text: "87");
  final TextEditingController _passwordController =
      TextEditingController(text: "avaliacao2022");
  final CacheManager cacheManager = CacheManager();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkTokenInCache();

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
  }

  // Função para verificar se o token já está no cache
  Future<void> _checkTokenInCache() async {
    String? token = await cacheManager
        .getFromCache('userToken'); // Verifica o token no cache
    if (token != null && !JwtDecoder.isExpired(token)) {
      // Token válido, redireciona o usuário para a página inicial
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String nomeAluno = decodedToken['aluno_nome'] ?? 'Nome não disponível';
      String fotoAluno =
          decodedToken['aluno_url_foto'] ?? 'https://link-padrao.com/foto.png';
      String idMatricula = decodedToken['aluno_id'] ?? '0000';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePageAluno(
            nomeAluno: nomeAluno,
            fotoAluno: fotoAluno,
            idMatricula: idMatricula,
          ),
        ),
      );
    } else {
      // Token não existe ou expirou, permanece na tela de login
      await cacheManager.removeFromCache('userToken');
    }
  }

  // Future<void> _login() async {
  //   String username = _usernameController.text;
  //   String password = _passwordController.text;

  //   // Verifica se o usuário é um funcionário pelo sufixo no nome de usuário
  //   bool isFuncionario = username.endsWith('_adm');

  //   // URL de login
  //   String loginUrl = 'https://app.tresmarias.edu.br/login.php';

  //   try {
  //     print('Tentando fazer o POST');
  //     final response = await http.post(
  //       Uri.parse(loginUrl),
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body: {
  //         'username': username,
  //         'password': password,
  //       },
  //     );

  //     print('POST realizado');
  //     print('Resposta do servidor: ${response.body}');

  //     final data = jsonDecode(response.body);

  //     if (data['tokenAccess'] != null) {
  //       final token = data['tokenAccess'];
  //       await saveToken(token);

  //       // Decodifica o token para obter as informações do aluno
  //       Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

  //       // Extração dos dados do aluno
  //       String nomeAluno = decodedToken['aluno_nome'] ?? 'Nome não disponível';
  //       String fotoAluno = decodedToken['aluno_url_foto'] ??
  //           'https://link-padrao.com/foto.png';
  //       String idMatricula = decodedToken['aluno_id'] ?? '0000';

  //       if (isFuncionario) {
  //         Navigator.pushReplacementNamed(context, '/home_funcionario');
  //       } else {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => HomePageAluno(
  //               nomeAluno: nomeAluno,
  //               fotoAluno: fotoAluno,
  //               idMatricula: idMatricula,
  //             ),
  //           ),
  //         );
  //       }
  //     } else {
  //       _showErrorDialog('Falha no login',
  //           'Credenciais inválidas ou resposta inesperada do servidor.');
  //     }
  //   } catch (e) {
  //     // Trata erro de conexão
  //     _showErrorDialog('Erro de Conexão',
  //         'Não foi possível conectar ao servidor. Tente novamente mais tarde.');
  //     debugPrint('Erro de login: $e');
  //   }
  // }

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    bool isFuncionario = username.endsWith('_adm');
    String loginUrl = 'https://app.tresmarias.edu.br/login.php';

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);

      if (data['tokenAccess'] != null) {
        final token = data['tokenAccess'];
        print(token);
        await saveToken(token); // Salva o token localmente
        await cacheManager.saveToCache(
            'userToken', token); // Salva o token no cache

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String nomeAluno = decodedToken['aluno_nome'] ?? 'Nome não disponível';
        String fotoAluno = decodedToken['aluno_url_foto'] ??
            'https://link-padrao.com/foto.png';
        String idMatricula = decodedToken['aluno_id'] ?? '0000';

        if (isFuncionario) {
          Navigator.pushReplacementNamed(context, '/home_funcionario');
        } else {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HomePageAluno(
                      nomeAluno: nomeAluno,
                      fotoAluno: fotoAluno,
                      idMatricula: idMatricula,
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                }),
          );
        }
      } else {
        _showErrorDialog('Falha no login',
            'Credenciais inválidas ou resposta inesperada do servidor.');
      }
    } catch (e) {
      _showErrorDialog('Erro de Conexão',
          'Não foi possível conectar ao servidor. Tente novamente mais tarde.');
      debugPrint('Erro de login: $e');
    }
  }

  void decodeToken(String token) {
    bool isExpired = JwtDecoder.isExpired(token);
    if (isExpired) {
      print("O token expirou.");
    } else {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      print("Token decodificado: $decodedToken");

      String alunoId = decodedToken['aluno_id'];
      String alunoNome = decodedToken['aluno_nome'];
      String alunoEmail = decodedToken['aluno_email'];
      String fotoUrl = decodedToken['aluno_url_foto'];

      print("ID do Aluno: $alunoId");
      print("Nome do Aluno: $alunoNome");
      print("Email do Aluno: $alunoEmail");
      print("Foto do Aluno: $fotoUrl");
    }
  }

  void _animateLoginButton() {
    // Inicia a animação quando o botão de login for pressionado
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchProtectedData(String token) async {
    String apiUrl = 'https://seu-servidor.com.br/protected-data';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('token: ${token}');
    print(response.body);
    if (response.statusCode == 200) {
      print('Dados recebidos: ${response.body}');
    } else {
      print('Erro: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gato dançando
                Image.asset(
                  'assets/images/gato.gif',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 40),
                const Text('Login:'),
                const SizedBox(height: 15),
                TextfieldCustom(
                  controller: _usernameController,
                  obscureText: false,
                  fillColor: Colors.grey.shade200,
                  cursorColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 20),
                const Text('Senha:'),
                const SizedBox(height: 15),
                TextfieldCustom(
                  controller: _passwordController,
                  obscureText: true,
                  fillColor: Colors.grey.shade200,
                  showPasswordtoggle: true,
                  cursorColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 40),

                // Animação do botão de login
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: CustomButton(
                        text: _isLoading
                            ? ''
                            : 'Login', // Oculta o texto enquanto carrega
                        backgroundColor: Colors.blue,
                        onPressed: () {
                          _animateLoginButton();
                          _login();
                        },
                        loading: _isLoading,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
