class BotResponse{
  final String response;  

  BotResponse({required this.response});
 static  Map<String, String> responses = {
  "provide_quantity": "تم تسجيل كمية الزيت: {amount} لتر. ما هو عنوانك؟",
  "provide_address": "شكرًا! الآن اختر هديتك: بطاقة تسوق، كوبون خصم، أو تبرع؟",
  "choose_gift": "تم اختيار هديتك: {gift}. الآن اضغط إرسال لإكمال الطلب.",
  "submit_order": "تم إرسال طلبك بنجاح! سيتم التواصل معك قريبًا.",
  "greeting": "مرحبًا! كيف يمكنني مساعدتك اليوم؟",
  "goodbye": "إلى اللقاء! لا تتردد في العودة إذا احتجت لأي مساعدة.",
  "fallback": "لم أفهم ذلك تمامًا، هل يمكنك التوضيح أكثر؟"
};
static String getResponse(String response){
  return responses[response] ?? "لم أفهم ذلك!";

}


}