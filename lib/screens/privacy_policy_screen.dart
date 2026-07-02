import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '隐私政策',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: _PolicyContent(),
      ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  const _PolicyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Title('火锅捞捞 隐私政策'),
        _Meta('最后更新日期：2025年6月'),
        SizedBox(height: 20),
        _Body(
          '欢迎使用火锅捞捞（以下简称"本应用"）。本应用由个人开发者开发并发布。'
          '我们非常重视您的个人隐私，请您仔细阅读本隐私政策。',
        ),
        SizedBox(height: 20),

        _Section('一、我们收集的信息'),
        _Body('本应用为工具类应用，设计目标是尽量少收集或不收集用户个人数据。'),
        SizedBox(height: 8),
        _BulletItem('相册选图', '仅当您主动使用"照片识别食材"功能时，本应用会调起系统相册选择器，由系统代为选图，本应用不申请相机或存储权限。图片仅在本地设备上处理，不上传至任何服务器。'),
        _BulletItem('本地存储', '您设置的忌口偏好、自定义蘸料方案等数据仅保存在您的本地设备上（通过系统 SharedPreferences），不会上传或共享。'),
        _BulletItem('震动权限', '用于倒计时结束时的震动提醒，不涉及任何数据收集。'),
        SizedBox(height: 20),

        _Section('二、我们不收集的信息'),
        _Body('本应用不收集以下任何信息：'),
        _SimpleItem('• 您的姓名、手机号、邮箱等个人身份信息'),
        _SimpleItem('• 您的位置信息'),
        _SimpleItem('• 设备唯一标识符（如 IMEI、广告 ID）'),
        _SimpleItem('• 使用行为数据或统计数据'),
        _SimpleItem('• 本应用不内置任何第三方统计 SDK 或广告 SDK'),
        SizedBox(height: 20),

        _Section('三、权限说明'),
        _BulletItem('VIBRATE（震动）', '震动提醒，无需用户授权，不涉及数据收集。本应用未申请其他任何权限：相册选图通过系统选择器完成，不需要存储或相机权限。'),
        SizedBox(height: 20),

        _Section('四、第三方服务'),
        _Body(
          '本应用当前版本不集成任何第三方 SDK（包括但不限于广告、统计、推送、支付）。'
          '所有功能均在本地运行，不与任何第三方服务器通信。',
        ),
        SizedBox(height: 20),

        _Section('五、数据安全'),
        _Body(
          '您的所有使用数据（偏好设置、自定义方案等）均存储在本地设备中，'
          '卸载本应用将自动清除全部本地数据。',
        ),
        SizedBox(height: 20),

        _Section('六、儿童隐私'),
        _Body('本应用不针对 14 周岁以下未成年人，也不主动收集未成年人的任何个人信息。'),
        SizedBox(height: 20),

        _Section('七、政策变更'),
        _Body(
          '如本隐私政策发生变更，我们将在应用内通过版本更新日志告知您。'
          '继续使用本应用视为您接受更新后的政策。',
        ),
        SizedBox(height: 20),

        _Section('八、联系我们'),
        _Body('如您对本隐私政策有任何疑问，请通过"我的 → 意见反馈"联系我们。'),
        SizedBox(height: 32),

        _Meta('本政策适用于火锅捞捞 Android 版本。'),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
  );
}

class _Meta extends StatelessWidget {
  final String text;
  const _Meta(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
  );
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(color: Color(0xFFFFCC00), fontSize: 14, fontWeight: FontWeight.bold),
    ),
  );
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13, height: 1.7),
  );
}

class _BulletItem extends StatelessWidget {
  final String title;
  final String desc;
  const _BulletItem(this.title, this.desc);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: Color(0xFFFFCC00), fontSize: 13)),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '$title：', style: const TextStyle(color: Colors.white, fontSize: 13)),
                TextSpan(text: desc, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13, height: 1.6)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SimpleItem extends StatelessWidget {
  final String text;
  const _SimpleItem(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13, height: 1.6)),
  );
}
