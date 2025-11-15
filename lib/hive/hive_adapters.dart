import 'package:f2fa/models/models.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

@GenerateAdapters([
  AdapterSpec<Totp>(),
  AdapterSpec<WebdavConfig>(),
  AdapterSpec<ThemeLanguage>(),
  AdapterSpec<ThemeMode>(),
  AdapterSpec<AuthMethod>(),
])
part 'hive_adapters.g.dart';
