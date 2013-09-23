package elmortem.game.senses.pathfinding {
	import elmortem.game.senses.ISense;
	import flash.geom.Point;
	
	public class PathFinder implements ISense {
		
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		// Уникальный номер воды которым заполняется копия маски проходимости
		private static const WATER_KEY:int = 999;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _mapArr:Array;
		private var _mapMask:Array; // Копия маски карты
		private var _mapDirs:Array; // Направления
		private var _mapWidth:int; // Ширина карты
		private var _mapHeight:int; // Высота карты
		
		private var _freeCell:Array; // Вид свободной ячейки
		private var _maxIterations:int; // Счетчик повторов
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function PathFinder() {
			_mapArr = null;
			_mapMask = null;
			_mapDirs = null;
			_mapWidth = 0;
			_mapHeight = 0;
			
			_freeCell = [ -1];
			_maxIterations = 50;
		}
		
		public function free():void {
			_mapArr = null;
			_mapMask = null;
			_mapDirs = null;
			_freeCell = null;
		}
		public function get senseName():String {
			return "pathFinder";
		}
		public function update(delta:Number):void {}
		
		public function setMap(mapArr:Array):void {
			//_mapArr = mapArr.concat();
			_mapArr = mapArr;
			_mapWidth = _mapArr.length; // Ширина карты
			_mapHeight = _mapArr[0].length; // Высота карты
			
			_mapMask = null;
			_mapDirs = null;
		}
		private function reset():void {
			// Копируем маску мира
			// И заполняем массив направлений нулевыми координатами
			var colMask:Array; // Строка для карты
			var colDirs:Array; // Строка для направлений
			
			_mapMask = [];
			_mapDirs = [];
			
			for (var x:int = 0; x < _mapWidth; x++) {
				// Новые строки
				colMask = [];
				colDirs = [];
				for (var y:int = 0; y < _mapHeight; y++) {
					colMask.push(_mapArr[x][y]); // Копируем состояние клетки
					colDirs.push(new Point()); // Создаем нулевую коордианту направления
				}
				_mapMask.push(colMask);
				_mapDirs.push(colDirs);
			}
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		* Ищет путь и возвращает массив направлений
		*/
		public function findWay(start:Point, end:Point, mapArr:Array = null):Array/*Point*/{
			if (mapArr != null) setMap(mapArr);
			reset();
			
			if (!isFreeCell(end.x, end.y) || !isFreeCell(start.x, start.y) || (start.x == end.x && start.y == end.y)) return [];
			
			// Устанавливаем точку куда льем "воду"
			_mapMask[end.x][end.y] = WATER_KEY;
			
			// info чтобы не тратить время потом на инвертирование направлений,
			// мы "льем воду" сразу в конец маршрута и таким образом у нас будет
			// массив направлений в нужном порядке
			
			var counter:int = 0; // Счетчик проходов по карте
			
			// Выполняем проходы по карте
			while (counter < _maxIterations) {
				// Ищим путь / размазываем воду по маске проходимости
				for (var x:int = 0; x < _mapWidth; x++) {
					for (var y:int = 0; y < _mapHeight; y++) {
						// Если в текущей ячейке вода 
						if (_mapMask[x][y] == WATER_KEY)  {
							goWater(x, y); // то распространяем её в соседние ячейки
						}
					}
				}
				
				// Проверяем не попала-ли вода в точку финиша
				if (_mapMask[start.x][start.y] == WATER_KEY) {
					// Ура путь найден!
					return getWay(start, end);
				}
				
				counter++;
			}
			
			// Количество проходов исчерпано, путь не найден
			// Возвращаем пустой массив
			return [];
		}
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		/**
		* Распространяет воду из текущей клетки в соседнии
		*/
		private function goWater(ax:int, ay:int):void {
			// Если клеточка слева свободна
			if (inMap(ax - 1, ay) && isFreeCell(ax - 1, ay)) {
				_mapMask[ax - 1][ay] = WATER_KEY; // Заполняем её водой
				// Запоминаем из какой клетки вода пришла
				_mapDirs[ax - 1][ay].x = ax;
				_mapDirs[ax - 1][ay].y = ay;
			}
			
			// Если клеточка снизу свободна
			if (inMap(ax, ay + 1) && isFreeCell(ax, ay + 1)) {
				_mapMask[ax][ay + 1] = WATER_KEY; // Заполняем её водой
				// Запоминаем из какой клетки вода пришла
				_mapDirs[ax][ay + 1].x = ax;
				_mapDirs[ax][ay + 1].y = ay;
			}
			
			// Если клеточка справа свободна
			if (inMap(ax + 1, ay) && isFreeCell(ax + 1, ay)) {
				_mapMask[ax + 1][ay] = WATER_KEY; // Заполняем её водой
				// Запоминаем из какой клетки вода пришла
				_mapDirs[ax + 1][ay].x = ax;
				_mapDirs[ax + 1][ay].y = ay;
			}
				
			// Есле клеточка сверху свободна
			if (inMap(ax, ay - 1) && isFreeCell(ax, ay - 1)) {
				_mapMask[ax][ay - 1] = WATER_KEY; // Заполняем её водой
				// Запоминаем из какой клетки вода пришла
				_mapDirs[ax][ay - 1].x = ax;
				_mapDirs[ax][ay - 1].y = ay;
			}
		}
		
		/**
		* Проверяет выход за приделы карты
		*/
		private function inMap(ax:int, ay:int):Boolean {
			if (ax >= 0 && ax < _mapWidth && ay >= 0 && ay < _mapHeight) {
				return true;
			} else {
				return false;
			}
		}
		private function isFreeCell(ax:int, ay:int):Boolean {
			for (var i:int = 0; i < _freeCell.length; i++) {
				if (_mapMask[ax][ay] == _freeCell[i]) {
					return true;
				}
			}
			return false;
		}
		
		/**
		* Возвращает путь от точки start до точки end
		*/
		private function getWay(start:Point, end:Point):Array/*Point*/ {
			var way:Array = [];
			var p1:Point = new Point(start.x, start.y);
			var p2:Point = new Point();
			
			// Добавляем в маршрут первую точку
			//way.push(new Point(start.x, start.y));
			
			// Добавляем в маршрут все остальные точки
			// пока не дойдем до конца
			var i:int = 0;
			while (i < _mapWidth * _mapHeight) {
				p2.x = _mapDirs[p1.x][p1.y].x; // Получаем новую точку из направления предыдущей
				p2.y = _mapDirs[p1.x][p1.y].y;
				
				way.push(new Point(p2.x, p2.y)); // Добавляем новую точку в маршрут
				p1.x = p2.x;
				p1.y = p2.y;
				
				// Проверяем не добрались ли до конца
				if (p1.x == end.x && p1.y == end.y) {
					break;
				}
				
				i++;
			}
			return way;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
				
		/**
		* Устанавливает вид свободной ячейки
		*/
		public function set freeCell(value:Array):void {
			_freeCell = value;
		}
		
		/**
		* Устанавливает кол-во проходов по карте
		*/
		public function set maxIterations(value:int):void {
			_maxIterations = value;
		}

	}

}