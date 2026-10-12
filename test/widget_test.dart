import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_amogus/main.dart';

void main() {
  testWidgets('Регистрация, вход, добавление вещи и выход', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const Prilozhenie());
    expect(find.text(nazvanieProekta), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Войти'), findsOneWidget);

    await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Создать аккаунт'));
    await tester.pumpAndSettle();
    expect(find.text('Введите имя'), findsOneWidget);

    final polya = find.byType(TextFormField);
    await tester.enterText(polya.at(0), 'Айгерим');
    await tester.enterText(polya.at(1), 'aigerim@mail.kz');
    await tester.enterText(polya.at(2), '8777');
    await tester.enterText(polya.at(3), 'Астана');
    await tester.enterText(polya.at(4), 'qwerty1');
    await tester.enterText(polya.at(5), 'qwerty1');
    await tester.tap(find.text('Создать аккаунт'));
    await tester.pumpAndSettle();
    expect(find.text('Номер в формате +7 777 123 45 67'), findsOneWidget);

    await tester.enterText(polya.at(2), '+7 777 123 45 67');
    await tester.tap(find.text('Создать аккаунт'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'qwerty1');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Здравствуйте, Айгерим!'), findsOneWidget);

    await tester.tap(find.text('Перейти к вещам'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle();
    expect(find.text('Напишите, какую вещь отдаёте'), findsOneWidget);

    final forma = find.byType(TextFormField);
    await tester.enterText(forma.at(0), 'Детская коляска');
    await tester.enterText(forma.at(2), 'Есиль, ул. Сыганак 10');
    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle();
    expect(find.text('Детская коляска'), findsOneWidget);
    expect(find.text(statusNovyy), findsOneWidget);

    await tester.tap(find.text('Детская коляска'));
    await tester.pumpAndSettle();
    expect(find.text(statusGotov), findsOneWidget);

    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(find.text('+77771234567'), findsOneWidget);
    expect(find.text('1 из 1'), findsOneWidget);

    await tester.tap(find.text('Выйти из аккаунта'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    expect(find.text('Войти'), findsOneWidget);
    expect(Hranilishe.tekushiy, isNull);
  });
}
