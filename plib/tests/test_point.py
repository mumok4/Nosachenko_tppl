import pytest

from plib import Point

@pytest.fixture
def points():
    return Point(0,0), Point(0,2)





class TestPoint:

    def test_creation(self, points):
        p1, p2 = points
        assert p1.x == 0 and p1.y == 0

        assert isinstance(p1.x, int) == True and isinstance(p1.y, int) == True

        with pytest.raises(TypeError):
            Point(1.2,2.2)


    def test_add(self, points):
        p1, p2 = points

        assert p2 + p1 == Point(0, 2)


    def test_sub(self, points):
        p1,p2 = points

        assert p2 - p1 == Point(0, 2)
        assert p1 - p2 == -Point(0, 2)

        p2 -= p1
        assert p2 == Point(0, 2)


    def test_distance_to(self, points):
        p1,p2 = points

        assert p1.to(p2) == 2

    @pytest.mark.parametrize(
        "p1, p2, distance",
        [(Point(0, 0), Point(0, 10), 10),
         (Point(0,0), Point(10,0), 10),
         (Point(0,0), Point(1,1), 1.414)]
        )
    def test_distance_all_axis(self, p1, p2, distance):
        assert p1.to(p2) == pytest.approx(distance, 0.001)


    def test_jsonify(self, points):
        p1,p2 = points
        p2_json = p2.to_json()

        assert p2_json == '{"x": 0, "y": 2}'

        p2_from_json = Point.from_json(p2_json)

        assert p2_from_json == Point(0, 2)


    def test_naming(self):
        p1 = Point(0, 0)
        assert str(p1) == "Point(0, 0)"


    def test_center(self, points):
        p1, p2 = points

        assert p1.is_center() == True
        assert p2.is_center() == False
