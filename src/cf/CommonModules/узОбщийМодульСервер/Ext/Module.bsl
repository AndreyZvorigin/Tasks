﻿
Процедура ОтправитьПисьмо(ДопПараметры) Экспорт
	
	ВажностьЗадачи = ДопПараметры.ВажностьЗадачи;
	ТекстПисьма = ДопПараметры.ТекстПисьма;
	ТемаПисьма = ДопПараметры.ТемаПисьма;

	Если ДопПараметры.Свойство("МассивПользователейКому") Тогда
		МассивПользователей = ДопПараметры.МассивПользователейКому;
	Иначе		
		МассивПользователей = Новый Массив();
		МассивПользователей.Добавить(ДопПараметры.ПользовательКому);
	Конецесли;
	
	ТЗАдресаЭлектроннойПочты = ПолучитьТЗАдресаЭлектроннойПочты(МассивПользователей);	
	
	Для каждого СтрокаТЗАдресаЭлектроннойПочты из ТЗАдресаЭлектроннойПочты цикл
		ПользовательКому = СтрокаТЗАдресаЭлектроннойПочты.Пользователь;
		Если НЕ ЗначениеЗаполнено(СтрокаТЗАдресаЭлектроннойПочты.АдресЭлектроннойПочты) Тогда
			
			пТекстСообщения = узОбщийМодульСервер.ПолучитьТекстСообщения("Ошибка! при отправке письма не удалось получить адреса электронной почты для [%1]","2");
			пТекстСообщения = СтрШаблон(пТекстСообщения,ПользовательКому);
			Сообщить(пТекстСообщения);			

		Конецесли;
	Конеццикла;
	
	ТекПользователь = Пользователи.ТекущийПользователь();
	ДокОбъект = Документы.ЭлектронноеПисьмоИсходящее.СоздатьДокумент();	
	ДокОбъект.Дата = ТекущаяДата();
	ДокОбъект.Автор = ТекПользователь;
	
	Если ЗначениеЗаполнено(ВажностьЗадачи) Тогда
		ДокОбъект.Важность = Перечисления.ВариантыВажностиВзаимодействия[""+ВажностьЗадачи];
	Конецесли;
	ДокОбъект.Кодировка = "UTF-8";
	ДокОбъект.Ответственный = ТекПользователь;
	ДокОбъект.ОтправительПредставление = "1с: Управление задачами";
	ДокОбъект.СтатусПисьма = ПредопределенноеЗначение("Перечисление.СтатусыИсходящегоЭлектронногоПисьма.Исходящее");
	ДокОбъект.Текст = ТекстПисьма;
	ДокОбъект.Тема = ТемаПисьма;
	ДокОбъект.ТипТекста = ПредопределенноеЗначение("Перечисление.ТипыТекстовЭлектронныхПисем.ПростойТекст");
	ДокОбъект.УчетнаяЗапись = ПредопределенноеЗначение("Справочник.УчетныеЗаписиЭлектроннойПочты.СистемнаяУчетнаяЗаписьЭлектроннойПочты");
	ДокОбъект.УдалятьПослеОтправки = Истина;
	
	//ДокОбъект.ДатаКогдаОтправить = ;
	
	Для каждого СтрокаТЗАдресаЭлектроннойПочты из ТЗАдресаЭлектроннойПочты цикл
		АдресЭлектроннойПочты = СтрокаТЗАдресаЭлектроннойПочты.АдресЭлектроннойПочты;
		ПользовательКому = СтрокаТЗАдресаЭлектроннойПочты.Пользователь;
		
		СтрокаПолучателиПисьма = ДокОбъект.ПолучателиПисьма.Добавить();
		СтрокаПолучателиПисьма.Адрес         = АдресЭлектроннойПочты;
		СтрокаПолучателиПисьма.Представление = ""+ПользовательКому+" <"+АдресЭлектроннойПочты+">";
		СтрокаПолучателиПисьма.Контакт       = ПользовательКому;
	Конеццикла;
	ДокОбъект.СформироватьПредставленияКонтактов();
	ДокОбъект.Записать();	
КонецПроцедуры 

Функция ПолучитьТЗАдресаЭлектроннойПочты(МассивПользователей) 
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПользователиКонтактнаяИнформация.Ссылка КАК Пользователь,
	|	ПользователиКонтактнаяИнформация.АдресЭП КАК АдресЭлектроннойПочты
	|ИЗ
	|	Справочник.Пользователи.КонтактнаяИнформация КАК ПользователиКонтактнаяИнформация
	|ГДЕ
	|	ПользователиКонтактнаяИнформация.Ссылка В(&МассивПользователей)
	|	И ПользователиКонтактнаяИнформация.Тип = &Тип
	|	И ПользователиКонтактнаяИнформация.Вид = &Вид
	|";
	
	Запрос.УстановитьПараметр("Вид", ПредопределенноеЗначение("Справочник.ВидыКонтактнойИнформации.EmailПользователя"));
	Запрос.УстановитьПараметр("МассивПользователей", МассивПользователей);
	Запрос.УстановитьПараметр("Тип", ПредопределенноеЗначение("Перечисление.ТипыКонтактнойИнформации.АдресЭлектроннойПочты"));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ТЗАдресаЭлектроннойПочты = РезультатЗапроса.Выгрузить();
	Возврат ТЗАдресаЭлектроннойПочты;
КонецФункции 

Процедура узЗагрузкаИзмененийИзХранилища() Экспорт
	
	ОбщегоНазначения.ПриНачалеВыполненияРегламентногоЗадания(Метаданные.РегламентныеЗадания.узЗагрузкаИзмененийИзХранилища);	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	узКонфигурации.Ссылка КАК Конфигурация,
	|	узКонфигурации.ПолучатьИзмененияИзХранилища
	|ИЗ
	|	Справочник.узКонфигурации КАК узКонфигурации
	|ГДЕ
	|	узКонфигурации.ПолучатьИзмененияИзХранилища
	|	И НЕ узКонфигурации.ПометкаУдаления";
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	Конецесли;
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		пКонфигурация = Выборка.Конфигурация;
		
		ОбрОбъект = Обработки.узЗагрузкаИзмененийИзХранилища.Создать();
		ОбрОбъект.Конфигурация = пКонфигурация;
		ОбрОбъект.ВерсияС = Справочники.узИсторияКонфигураций.ПолучитьПоследнююЗагруженнуюВерсию(пКонфигурация);
		РезультатФункции = ОбрОбъект.ЗагрузитьИзмененияИзХранилища();
		
		пТекстСообщения = узОбщийМодульСервер.ПолучитьТекстСообщения("Загружены изменения для конфигурации [%1] с версии [%2]","3");
		пТекстСообщения = СтрШаблон(пТекстСообщения,пКонфигурация,ОбрОбъект.ВерсияС);
		Сообщить(пТекстСообщения);			
		
	КонецЦикла;
КонецПроцедуры

Функция узОткрыватьСправочникЗадачиПриНачалеРаботыСистемы() Экспорт
	пТекущийПользователь = Пользователи.ТекущийПользователь();
	Возврат пТекущийПользователь.узОткрыватьСправочникЗадачиПриНачалеРаботыСистемы;
КонецФункции 

// Производит запись в служебных регистр информации о наличии заметки по предмету.
//
// Параметры совпадают с параметрами обработчика при записи у элемента справочника.
Процедура узПроверитьНаличиеЗаметокПоПредметуПриЗаписи(Источник, Отказ) Экспорт
	
	Если Источник.ОбменДанными.Загрузка Тогда 
		Возврат; 
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если Не ЗначениеЗаполнено(Источник.Предмет) Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	ТекстЗапроса = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Заметки.Ссылка
	|ИЗ
	|	Справочник.Заметки КАК Заметки
	|ГДЕ
	|	Заметки.Предмет = &Предмет
	|	И Заметки.Автор = &Пользователь
	|	И Заметки.ПометкаУдаления = ЛОЖЬ";
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("Предмет", Источник.Предмет);
	Запрос.УстановитьПараметр("Пользователь", Источник.Автор);
	Выборка = Запрос.Выполнить().Выбрать();
	ЕстьЗаметки = Выборка.Количество() > 0;

	НаборЗаписей = РегистрыСведений.узНаличиеЗаметокПоПредмету.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Автор.Установить(Источник.Автор);
	НаборЗаписей.Отбор.Предмет.Установить(Источник.Предмет);
	
	Если ЕстьЗаметки Тогда 
		Если НаборЗаписей.Количество() = 0 Тогда
			НоваяЗапись = НаборЗаписей.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяЗапись, Источник);
			НоваяЗапись.ЕстьЗаметки = Истина;				
		Иначе
			Для Каждого Запись Из НаборЗаписей Цикл
				Запись.ЕстьЗаметки = Истина;
			КонецЦикла;
		КонецЕсли;
	Иначе
		НаборЗаписей.Очистить();
	КонецЕсли;

	НаборЗаписей.Записать();
КонецПроцедуры

Функция ПолучитьHTMLMarkdown(ЗНАЧ ТекстСодержания) Экспорт
	Перем HTMLMarkdown;
	
	ТекстСодержания = СтрЗаменить(ТекстСодержания,Символы.ПС,"\n"); 
	ТекстСодержания = СтрЗаменить(ТекстСодержания,"'",""""); //&quot	
	
	узМакетHTML = ПолучитьОбщийМакет("узМакетHTML");
	узМакетJS = ПолучитьОбщийМакет("узМакетJS");
	узМакетCSS = ПолучитьОбщийМакет("узМакетCSS");
	
	ТекстСкриптаJS = узМакетJS.ПолучитьТекст();
	ТекстCSSМакет = узМакетCSS.ПолучитьТекст();	
	
	HTMLMarkdown = узМакетHTML.ПолучитьТекст();
	HTMLMarkdown = СтрЗаменить(HTMLMarkdown,"...ТекстJS...",ТекстСкриптаJS);
	HTMLMarkdown = СтрЗаменить(HTMLMarkdown,"...ТекстCSS...",ТекстCSSМакет);
	HTMLMarkdown = СтрЗаменить(HTMLMarkdown,"...ТекстHTML...",ТекстСодержания);	
	
	Возврат HTMLMarkdown;
КонецФункции

Функция ПолучитьПользователяПоПользователюХранилища(ПользовательХранилища) Экспорт
	Перем пПользователь;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Пользователи.Ссылка
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|ГДЕ
		|	Пользователи.узПользовательХранилища = &ПользовательХранилища
		|	И Пользователи.Недействителен = ЛОЖЬ";
	
	Запрос.УстановитьПараметр("ПользовательХранилища", ПользовательХранилища);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат пПользователь;
	Конецесли;
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		пПользователь = Выборка.Ссылка;	
	КонецЦикла;
	
	Возврат пПользователь;
КонецФункции 

Процедура узСообщить(ТекстРусский, КодСообщения) Экспорт
	ТекстСообщения = ПолучитьТекстСообщения(ТекстРусский, КодСообщения);
	Сообщить(ТекстСообщения);
КонецПроцедуры 

Функция ПолучитьТекстСообщения(ТекстРусский, КодСообщения) Экспорт
	Возврат РегистрыСведений.узСловарь.ПолучитьТекстСообщения(ТекстРусский, КодСообщения);
КонецФункции

Функция ПолучитьСтруктуруСообщений(МассивКодовСообщений) Экспорт                          
	Возврат РегистрыСведений.узСловарь.ПолучитьСтруктуруСообщений(МассивКодовСообщений);
КонецФункции 

