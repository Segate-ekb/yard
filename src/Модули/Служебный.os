// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/yard/
// ----------------------------------------------------------

#Использовать semver

// Функция - преобразует строковое значение даты в формате "дд.мм.гг" или "дд.мм.гггг" в дату
//
// Параметры:
//	ДатаСтрокой     - Строка     - дата в формате "дд.мм.гг" или "дд.мм.гггг"
//
// Возвращаемое значение:
//	Дата     - преобразованное значение
//
Функция ДатаИзСтроки(Знач ДатаСтрокой) Экспорт

	ВремЧастиДаты = СтрРазделить(ДатаСтрокой, ".");

	КоличествоЧастейДаты = 3;

	Если ВремЧастиДаты.Количество() < КоличествоЧастейДаты Тогда
		Возврат '00010101000000';
	КонецЕсли;

	Попытка
		Если СтрДлина(ВремЧастиДаты[2]) = 4 Тогда
			Возврат Дата(СтрШаблон("%1%2%3%4", ВремЧастиДаты[2], ВремЧастиДаты[1], ВремЧастиДаты[0], "000000"));
		ИначеЕсли СтрДлина(ВремЧастиДаты[2]) = 2 Тогда
			Возврат Дата(СтрШаблон("20%1%2%3%4", ВремЧастиДаты[2], ВремЧастиДаты[1], ВремЧастиДаты[0], "000000"));
		Иначе
			Возврат '00010101000000';
		КонецЕсли;
	Исключение
		Возврат '00010101000000';
	КонецПопытки;

КонецФункции // ДатаИзСтроки()

// Процедура - Выполняет сравнение версий по соглашению SEMVER
//
// Параметры:
//   СтрокаВерсия1 - Строка - Строковое представление версии типа "1.0.0.0"
//   СтрокаВерсия2 - Строка - Строковое представление версии типа "1.0.0.0"
//
// Возвращаемое значение:
//   Число - результат сравнения в числе (0 = Равны, -1 = Меньше, 1 = Больше), относительно первой версии (СтрокаВерсия1)
// Пример, 
//  (-1) - СтрокаВерсия1 меньше (<) СтрокаВерсия2
//  (1) - СтрокаВерсия1 больше (>) СтрокаВерсия2
//  (0) - СтрокаВерсия1 равна (=) СтрокаВерсия2
//
Функция СравнитьВерсии(Знач СтрокаВерсии1, Знач СтрокаВерсии2) Экспорт

	МажорнаяВерсия1 = СокрЛП(Лев(СтрокаВерсии1, СтрНайти(СтрокаВерсии1, ".") - 1)) + ".0.0";
	МажорнаяВерсия2 = СокрЛП(Лев(СтрокаВерсии2, СтрНайти(СтрокаВерсии2, ".") - 1)) + ".0.0";

	РезультатСравнения = Версии.СравнитьВерсии(МажорнаяВерсия1, МажорнаяВерсия2);

	Если НЕ РезультатСравнения = 0 Тогда
		Возврат РезультатСравнения;
	КонецЕсли;

	МинорнаяВерсия1 = Сред(СтрокаВерсии1, СтрНайти(СтрокаВерсии1, ".") + 1);
	МинорнаяВерсия2 = Сред(СтрокаВерсии2, СтрНайти(СтрокаВерсии2, ".") + 1);

	Возврат Версии.СравнитьВерсии(МинорнаяВерсия1, МинорнаяВерсия2);
	
КонецФункции // СравнитьВерсии()

// Процедура - сортирует 4-х элементный массив номеров версий согласно соглашению SEMVER
//
// Параметры:
//	МассивВерсий     - Массив(Строка)     - массив номеров версий
//	Порядок          - Строка             - принимает значение "ВОЗР" или "УБЫВ"
//
Процедура СортироватьВерсии(МассивВерсий, Порядок = "ВОЗР") Экспорт

	МажорныеВерсии = Новый Соответствие();
	МассивМажорныхВерсий = Новый Массив();
	Для й = 0 По МассивВерсий.ВГраница() Цикл
		МажорнаяВерсия = СокрЛП(Лев(МассивВерсий[й], СтрНайти(МассивВерсий[й], ".") - 1)) + ".0.0";
		Если МажорныеВерсии[МажорнаяВерсия] = Неопределено Тогда
			МажорныеВерсии.Вставить(МажорнаяВерсия, Новый Массив());
			МассивМажорныхВерсий.Добавить(МажорнаяВерсия);
		КонецЕсли;
		МажорныеВерсии[МажорнаяВерсия].Добавить(Сред(МассивВерсий[й], СтрНайти(МассивВерсий[й], ".") + 1));
	КонецЦикла;

	Версии.СортироватьВерсии(МассивМажорныхВерсий, Порядок);

	МассивВерсий = Новый Массив();

	Для Каждого ТекВерсия Из МассивМажорныхВерсий Цикл
		МинорныеВерсии = МажорныеВерсии[ТекВерсия];
		Версии.СортироватьВерсии(МинорныеВерсии, Порядок);
		Для Каждого ТекЗначение Из МинорныеВерсии Цикл
			МажорнаяВерсия = СокрЛП(Лев(ТекВерсия, СтрНайти(ТекВерсия, ".") - 1));
			МассивВерсий.Добавить(СтрШаблон("%1.%2", МажорнаяВерсия, ТекЗначение));
		КонецЦикла;
	КонецЦикла;

КонецПроцедуры // СортироватьВерсии()

// Процедура - сортирует массив описаний версий по номерам версий согласно соглашению SEMVER
//
// Параметры:
//	ОписанияВерсий         - Массив(Структура)   - массив описаний версий для сортировки
//      * Версия               - Строка              - номер версии
//      * Дата                 - Дата                - дата версии
//      * Путь                 - Строка              - относительный путь к странице версии
//      * ВерсииДляОбновления  - Массив              - список версий для обновления
//	Порядок                - Строка              - принимает значение "ВОЗР" или "УБЫВ"
//
Процедура СортироватьОписанияВерсийПоНомеру(ОписанияВерсий, Порядок = "ВОЗР") Экспорт

	СоответствиеОписаний = Новый Соответствие();

	МассивВерсий = Новый Массив();

	Для Каждого ТекОписание Из ОписанияВерсий Цикл
		СоответствиеОписаний.Вставить(ТекОписание.Версия, ТекОписание);
		МассивВерсий.Добавить(ТекОписание.Версия);
	КонецЦикла;

	СортироватьВерсии(МассивВерсий, Порядок);

	ОписанияВерсий = Новый Массив();

	Для Каждого ТекВерсия Из МассивВерсий Цикл
		ОписанияВерсий.Добавить(СоответствиеОписаний[ТекВерсия]);
	КонецЦикла;

КонецПроцедуры // СортироватьОписанияВерсийПоНомеру()

// Процедура - сортирует массив описаний версий по дате версий
//
// Параметры:
//	ОписанияВерсий         - Массив(Структура)   - массив описаний версий для сортировки
//      * Версия               - Строка              - номер версии
//      * Дата                 - Дата                - дата версии
//      * Путь                 - Строка              - относительный путь к странице версии
//      * ВерсииДляОбновления  - Массив              - список версий для обновления
//	Порядок                - Строка              - принимает значение "ВОЗР" или "УБЫВ"
//
Процедура СортироватьОписанияВерсийПоДате(ОписанияВерсий, Порядок = "ВОЗР") Экспорт

	ТабВерсий = Новый ТаблицаЗначений();
	ТабВерсий.Колонки.Добавить("Дата", Новый ОписаниеТипов("Дата"));
	ТабВерсий.Колонки.Добавить("ОписаниеВерсии");

	Для Каждого ТекОписание Из ОписанияВерсий Цикл
		СтрокаВерсии = ТабВерсий.Добавить();
		СтрокаВерсии.Дата = ТекОписание.Дата;
		СтрокаВерсии.ОписаниеВерсии = ТекОписание;
	КонецЦикла;

	ТабВерсий.Сортировать(СтрШаблон("Дата %1", Порядок));

	ОписанияВерсий = ТабВерсий.ВыгрузитьКолонку("ОписаниеВерсии");

КонецПроцедуры // СортироватьОписанияВерсийПоДате()

// Функция - преобразует число в строку
// добавляя в начало "0" для 1-значных чисел
//
// Параметры:
//	ЗначениеЧисло     - Число     - преобразуемое число
//
// Возвращаемое значение:
//	Строка     - преобразованное значение
//
Функция ФорматДвузначноеЧисло(Знач ЗначениеЧисло)

	ЧислоСтрокой = Строка(ЗначениеЧисло);
	Если СтрДлина(ЧислоСтрокой) < 2 Тогда
		ЧислоСтрокой = "0" + ЧислоСтрокой;
	КонецЕсли;
	
	Возврат ЧислоСтрокой;

КонецФункции // ФорматДвузначноеЧисло()

// Функция - преобразует дату в сроковое представление в формате POSIX ("гггг-мм-дд чч:мм:сс")
//
// Параметры:
//	Дата     - Дата     - преобразуемая дата
//
// Возвращаемое значение:
//	Строка     - резудьтат преобразования в формате POSIX ("гггг-мм-дд чч:мм:сс")
//
Функция ДатаPOSIX(Знач Дата) Экспорт
	
	Возврат "" + Год(Дата) + "-" + ФорматДвузначноеЧисло(Месяц(Дата)) + "-" + ФорматДвузначноеЧисло(День(Дата)) + " "
	+ ФорматДвузначноеЧисло(Час(Дата)) + ":" + ФорматДвузначноеЧисло(Минута(Дата))
	+ ":" + ФорматДвузначноеЧисло(Секунда(Дата));
	
КонецФункции // ДатаPOSIX()

// Процедура - удаляет из текста HTML-страницы символы переноса строк, возврата каретки, пробелы и табуляции между тегами
//
// Параметры:
//	Текст     - Строка     - текста HTML-страницы
//
Процедура ОчиститьТекстСтраницыHTML(Текст) Экспорт

	Текст = СтрЗаменить(Текст, Символы.Таб, " ");

	Шаблон = "";
	Для й = 1 По 10 Цикл
		Шаблон = Шаблон + " ";
	КонецЦикла;

	Пока СтрДлина(Шаблон) > 1 Цикл
		Текст = СтрЗаменить(Текст, Шаблон, " ");
		Шаблон = Сред(Шаблон, 2);
	КонецЦикла;

	Шаблон = ">\s*?<";

	РВ = Новый РегулярноеВыражение(Шаблон);
	Совпадения = РВ.НайтиСовпадения(Текст);

	Для Каждого ТекСовпадение Из Совпадения Цикл
		Текст = СтрЗаменить(Текст, ТекСовпадение.Значение, "><");
	КонецЦикла;

	Шаблон = "[^>\s]\s{2,}?<";

	РВ = Новый РегулярноеВыражение(Шаблон);
	Совпадения = РВ.НайтиСовпадения(Текст);

	Для Каждого ТекСовпадение Из Совпадения Цикл
		Текст = СтрЗаменить(Текст, ТекСовпадение.Значение, Лев(ТекСовпадение.Значение, 1) +"<");
	КонецЦикла;

	Шаблон = ">\s{2,}?[^<\s]";

	РВ = Новый РегулярноеВыражение(Шаблон);
	Совпадения = РВ.НайтиСовпадения(Текст);

	Для Каждого ТекСовпадение Из Совпадения Цикл
		Текст = СтрЗаменить(Текст, ТекСовпадение.Значение, ">" + Прав(ТекСовпадение.Значение, 1));
	КонецЦикла;

КонецПроцедуры // ОчиститьТекстСтраницыHTML()

// Процедура - рекурсивно удаляет пустые каталоги вверх от указанного
//
// Параметры:
//  ПутьККаталогу     - Строка   - путь к каталогу, с которого начинается удаление
//  ДоКаталога        - Строка   - каталог верхнего уровня, до которого выполняется удаление
//
Процедура УдалитьПустыеКаталогиРекурсивно(Знач ПутьККаталогу, Знач ДоКаталога = "") Экспорт

	Если ОбъединитьПути(ПутьККаталогу, "0") = ОбъединитьПути(ДоКаталога, "0") Тогда
		Возврат;
	КонецЕсли;

	Каталог = Новый Файл(ПутьККаталогу);

	Если НЕ (Каталог.Существует() И Каталог.ЭтоКаталог()) Тогда
		Возврат;
	КонецЕсли;

	ФайлыВКаталоге = НайтиФайлы(ПутьККаталогу, "*.*");
	Если ФайлыВКаталоге.Количество() > 0 Тогда
		Возврат;
	КонецЕсли;

	УдалитьФайлы(ПутьККаталогу);

	УдалитьПустыеКаталогиРекурсивно(Каталог.Путь, ДоКаталога);

КонецПроцедуры // УдалитьПустыеКаталогиРекурсивно()

// Функция - возвращает общую для всех файлов часть пути
//
// Параметры:
//  ФайлыВАрхиве     - Массив(Файл)   - список файлов
//
// Возвращаемое значение:
//  Строка          - общая для всех файлов часть пути
//
Функция ОбщийПутьФайлов(МассивФайлов) Экспорт

	ОбщийПуть = Лев(МассивФайлов[0].ПолноеИмя, СтрДлина(МассивФайлов[0].ПолноеИмя) - СтрДлина(МассивФайлов[0].Имя));
	Для й = 1 По МассивФайлов.ВГраница() Цикл
		Если МассивФайлов[й].Имя = МассивФайлов[й].ПолноеИмя Тогда
			Прервать;
		КонецЕсли;
		Для к = 1 По СтрДлина(ОбщийПуть) Цикл
			Если НЕ Сред(ОбщийПуть, к, 1) = Сред(МассивФайлов[й].ПолноеИмя, к, 1) Тогда
				ОбщийПуть = Лев(ОбщийПуть, к - 1);
				Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;

	Возврат ОбщийПуть;

КонецФункции // ОбщийПутьФайлов()

// Функция - возвращает общую для всех файлов часть пути
//
// Параметры:
//  Путь               - Строка           - путь к каталогу шаблона релиза или к файлу описания (description.json)
//
// Возвращаемое значение:
//  Структура                             - описание релиза
//      *Идентификатор        - Строка         - идентификатор приложения
//      *Имя                  - Строка         - имя приложения
//      *Версия               - Строка         - номер версии приложения
//      *Дата                 - Дата           - дата версии приложения
//      *ВидДистрибутива      - Строка         - вид дистрибутива "Полный"/"Обновление"
//      *ВерсииДляОбновления  - Массив(Строка) - массив номеров версий, для которых преднозначено обновление
//
Функция ОписаниеРелиза(Знач Путь) Экспорт

	ВремФайл = Новый Файл(Путь);

	Если ВремФайл.ЭтоКаталог() Тогда
		ФайлыОписанийВерсий = ОбъединитьПути(Путь, "description.json");
	Иначе
		ФайлОписанияВерсии = Путь;
	КонецЕсли;

	ЧтениеОписания = Новый ЧтениеJSON();
	
	ЧтениеОписания.ОткрытьФайл(ФайлОписанияВерсии, КодировкаТекста.UTF8);
	
	ОписаниеРелиза = ПрочитатьJSON(ЧтениеОписания, Ложь, , ФорматДатыJSON.ISO);
	
	ЧтениеОписания.Закрыть();

	Возврат ОписаниеРелиза;
	
КонецФункции // ОписаниеРелиза()
