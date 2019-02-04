from libc.math cimport sqrt, fabs, fmax, acos, cos, sin

cdef struct C2Data:
    double x
    double y

cdef struct CircleData:
    C2Data center
    double radius

cdef struct LineData:
    double a
    double b
    double c

cdef struct LineSegmentData:
    C2Data p1
    C2Data p2


# utility functions

cdef inline bint normalize_coefficients(double *coeffs, int count):
    cdef double divisor = 0
    while count:
        count -= 1
        if divisor:
            coeffs[count] = coeffs[count] / divisor
        elif coeffs[count]:
            divisor = coeffs[count]
            coeffs[count] = 1

    #there is a bug here: 0x + 0y == 1 returns validly

    return divisor != 0

cdef inline bint fapprox(double a, double b, double rtol=1e-9, atol=0):
    cdef epsilon
    epsilon = fmax(atol, rtol * fmax(1, fmax(a, b)))
    return fabs(a - b) <= fabs(epsilon)


"""
C2Data Functions
"""

# c2 ref out functions

cdef inline bint c2_add_vector(C2Data& out, const C2Data& ref, const C2Data& vector):
    out.x = ref.x + vector.x
    out.y = ref.y + vector.y
    return 1

cdef inline bint c2_sub_vector(C2Data& out, const C2Data& ref, const C2Data& vector):
    out.x = ref.x - vector.x
    out.y = ref.y - vector.y
    return 1

cdef inline bint c2_div_scalar(C2Data& out, const C2Data& vector, double scalar):
    if scalar == 0:
        return 0
    out.x = vector.x / scalar
    out.y = vector.y / scalar
    return 1

cdef inline bint c2_mul_scalar(C2Data& out, const C2Data& vector, double scalar):
    out.x = vector.x * scalar
    out.y = vector.y * scalar
    return 1

cdef inline bint c2_div_vector(C2Data& out, const C2Data& lhs, const C2Data& rhs):
    if rhs.x == 0 or rhs.y == 0:
        return 0
    out.x = lhs.x / rhs.x
    out.y = lhs.y / rhs.y
    return 1


cdef inline bint c2_mul_vector(C2Data& out, const C2Data& lhs, const C2Data& rhs):
    out.x = lhs.x * rhs.x
    out.y = lhs.y * rhs.y
    return 1

cdef inline bint c2_unit_vector(C2Data& out, const C2Data& vector):
    return c2_div_scalar(out, vector, c2_magnitude(vector))

cdef inline bint c2_rotate_vector(C2Data& out, const C2Data& vector, double radians):
    cdef double rad_cos = cos(radians)
    cdef double rad_sin = sin(radians)
    cdef double temp_x = vector.x # since out and vector can be the same pointer
    out.x = vector.x * rad_cos - vector.y * rad_sin
    out.y = temp_x * rad_sin + vector.y * rad_cos
    return 1

cdef inline bint c2_rotate_around(C2Data& out, const C2Data& center, const C2Data& point, double radians):
    c2_sub_vector(out, point, center)
    c2_rotate_vector(out, out, radians)
    c2_add_vector(out, center, out)
    return 1

cdef inline bint c2_vectors_acute_angle(double& radians, const C2Data& v1, const C2Data& v2):
    cdef double temp
    temp = c2_magnitude(v1) * c2_magnitude(v2)
    if temp == 0:
        return 0
    temp = c2_dot_vector(v1, v2) / temp
    (&radians)[0] = acos(temp)
    return 1

cdef inline bint c2_points_acute_angle(double& radians, const C2Data& p1, const C2Data& p2, const C2Data& p3):
    cdef C2Data v1, v2
    c2_sub_vector(v1, p1, p2)
    c2_sub_vector(v2, p3, p2)
    return c2_vectors_acute_angle(radians, v1, v2)


cdef inline bint c2_from_polar(C2Data& out, double radius, double radians):
    out.x = radius * cos(radians)
    out.y = radius * sin(radians)
    return 1

# c2 value functions

cdef inline C2Data c2_negative(const C2Data& value):
    return C2Data(-value.x, -value.y)

cdef inline double c2_cross_vector(const C2Data& lhs, const C2Data& rhs):
    return lhs.x * rhs.y - lhs.y * rhs.x

cdef inline double c2_dot_vector(const C2Data& lhs, const C2Data& rhs):
    return lhs.x * rhs.x + lhs.y * rhs.y

cdef inline double c2_magnitude(const C2Data& vector):
    return sqrt(c2_dot_vector(vector, vector))

cdef inline double c2_points_distance(const C2Data& p1, const C2Data& p2):
    cdef C2Data vector
    c2_sub_vector(vector, p1, p2)
    return c2_magnitude(vector)

cdef inline double c2_ccw(const C2Data& p1, const C2Data& p2, const C2Data& p3):
    return (p2.x - p1.x) * (p3.y - p1.y) - (p3.x - p1.x) * (p2.y - p1.y)

cdef inline bint c2_parallel(const C2Data& lhs, const C2Data& rhs, double rtol=1e-9, double atol=0):
    return fapprox(c2_cross_vector(lhs, rhs), 0, rtol, atol)

cdef inline bint c2_orthogonal(const C2Data& lhs, const C2Data& rhs, double rtol=1e-9, double atol=0):
    return fapprox(c2_dot_vector(lhs, rhs), 0, rtol, atol)

cdef inline bint c2_approx(const C2Data& lhs, const C2Data& rhs, double rtol=1e-9, double atol=0):
    return fapprox(lhs.x, rhs.x, rtol, atol) and fapprox(lhs.y, rhs.y, rtol, atol)

cdef inline int c2_cmp_points(const C2Data& lhs, const C2Data& rhs):
    if lhs.x > rhs.x:
        return 1
    if lhs.x < rhs.x:
        return -1
    if lhs.y > rhs.y:
        return 1
    if lhs.y < rhs.y:
        return -1
    return 0

"""
LineData Functions
"""

cdef inline bint line_by_points(LineData& out, const C2Data& p1, const C2Data& p2):
    out.a = p1.y - p2.y
    out.b = p2.x - p1.x
    out.c = out.a * p1.y - out.b - p1.x
    return normalize_coefficients(<double*>&out, 3)

cdef inline bint line_translate(LineData& out, const LineData& line, const C2Data& vec):
    out.a = line.a * (line.c + line.b * vec.y)
    out.b = line.b * (line.c + line.a * vec.x)
    out.c = line.c ** 2
    out.c += line.a * line.c * vec.x
    out.c += line.b * line.c * vec.y
    out.c += line.a * line.b * vec.x * vec.y
    return normalize_coefficients(<double*>&out, 3)

cdef inline bint line_perpendicular(LineData& out, const LineData& line, const C2Data& point):
    #todo: check contains
    out.a = -line.b
    out.b = line.a
    out.c = line.a * point.y - line.b * point.x
    return normalize_coefficients(<double*>&out, 3)

cdef inline bint line_parallel(LineData& out, const LineData& line, const C2Data& point):
    out.a = line.a
    out.b = line.b
    out.c = line.a * point.x + line.b * point.y
    return normalize_coefficients(<double*>&out, 3)

cdef inline void line_closest_point(C2Data& out, const LineData& line, const C2Data& point):
    cdef LineData perp
    if not line_perpendicular(perp, line, point):
        (&out)[0] = point
    else:
        line_line_intersect(out, line, perp)

cdef inline bint line_contains_point(const LineData& line, const C2Data& point, double rtol=1e-9, double atol=0):
    return fapprox(line_constant(line, point), line.c, rtol, atol)

cdef inline bint line_line_intersect(C2Data& out, const LineData& l1, const LineData& l2):
    cdef det = l1.a * l2.b - l1.b * l2.a
    if det == 0:
        return 0
    out.x = (l2.b * l1.c - l1.b * l2.c) / det
    out.y = (l1.a * l2.c - l2.a * l1.c) / det
    return 1

cdef inline bint line_x_of(double& out, const LineData& line, double y):
    if line.a == 0:
        return 0
    (&out)[0] = (line.c - line.b * y) / line.a
    return 1

cdef inline bint line_y_of(double& out, const LineData& line, double x):
    if line.b == 0:
        return 0
    (&out)[0] = (line.c - line.a * x) / line.b

cdef inline double line_constant(const LineData& line, const C2Data& point):
    return line.a * point.x + line.b * point.y

cdef inline bint line_normal(C2Data& out, const LineData& line):
    out.x = line.a
    out.y = line.b
    return c2_unit_vector(out, out)


cdef inline bint line_eq(const LineData& l1, const LineData& l2, rtol=1e-9, atol=0):
    return fapprox(l1.a, l2.a, rtol, atol) and fapprox(l1.b, l2.b, rtol, atol) and fapprox(l1.c, l2.c, rtol, atol)

"""
LineSegment Functions
"""

# ref functions

cdef inline bint segment_vector(C2Data& out, const LineSegmentData& segment):
    return c2_sub_vector(out, segment.p2, segment.p1)

cdef inline bint segment_translate(LineSegmentData& out, const LineSegmentData& segment, const C2Data& vector):
    return c2_add_vector(out.p1, segment.p1, vector) and c2_add_vector(out.p2, segment.p2, vector)

cdef inline bint segment_center(C2Data& out, const LineSegmentData& segment):
    cdef C2Data temp
    if not segment_vector(temp, segment):
        return 0
    if not c2_div_scalar(temp, temp, 2.0):
        return 0
    if not c2_add_vector(out, segment.p1, temp):
        return 0
    return 1

cdef inline bint segment_segment_intersect(C2Data& out, const LineSegmentData& s1, const LineSegmentData& s2):
    if not segment_segment_does_intersect(s1, s2):
        return 0

    cdef LineData l1, l2
    if not line_by_points(l1, s1.p1, s1.p2):
        return 0
    if not line_by_points(l2, s2.p1, s2.p2):
        return 0
    return line_line_intersect(out, l1, l2)

# value functions

cdef inline LineSegmentData segment_normalized(const LineSegmentData& segment):
    if c2_cmp_points(segment.p1, segment.p2) <= 0:
        return segment
    return LineSegmentData(segment.p2, segment.p1)

cdef inline double segment_length(const LineSegmentData& segment):
    cdef C2Data vector
    segment_vector(vector, segment)
    return c2_magnitude(vector)

cdef inline bint segment_contains(const LineSegmentData& segment, const C2Data& point, double rtol=1e-9, atol=0):
    cdef C2Data ref_vector, test_vector
    segment_vector(ref_vector, segment)
    c2_sub_vector(test_vector, point, segment.p1)

    if not c2_parallel(ref_vector, test_vector, rtol, atol):
        return 0
    if 0 <= c2_dot_vector(ref_vector, test_vector) <= c2_dot_vector(ref_vector, ref_vector):
        return 1
    if c2_approx(segment.p1, point, rtol, atol):
        return 1
    if c2_approx(segment.p2, point, rtol, atol):
        return 1
    return 0

cdef inline bint segment_eq(const LineSegmentData& lhs, const LineSegmentData& rhs, double rtol=1e-9, atol=0):
    cdef LineSegmentData norm1, norm2
    norm1 = segment_normalized(lhs)
    norm2 = segment_normalized(rhs)
    return c2_approx(norm1.p1, norm2.p1, rtol, atol) and c2_approx(norm1.p2, norm2.p2, rtol, atol)

cdef inline bint segment_segment_does_intersect(const LineSegmentData& s1, const LineSegmentData& s2):
    cdef double ccw1, ccw2
    ccw1 = c2_ccw(s1.p1, s1.p2, s2.p1)
    ccw2 = c2_ccw(s1.p1, s1.p2, s2.p2)
    if ccw1 * ccw2 > 0:
        return False
    ccw1 = c2_ccw(s2.p1, s2.p2, s1.p1)
    ccw2 = c2_ccw(s2.p1, s2.p2, s1.p2)
    if ccw1 * ccw2 > 0:
        return False
    return True

"""
Circle Functions
"""

# ref functions

cdef inline int circle_circle_intersect(
        C2Data& p1,
        C2Data& p2,
        const CircleData& c1,
        const CircleData& c2,
        double rtol=1e-9,
        double atol=0
):
    """
    :return: The number of intersection points 0, 1, or 2, or -1 on error
    """

    return 0

# value functions

cdef inline double circle_equation(const CircleData& circle, const C2Data& point):
    cdef C2Data diff
    c2_sub_vector(diff, point, circle.center)
    return c2_dot_vector(diff, diff)

cdef inline bint circle_circle_does_intersect(const CircleData& c1, const CircleData& c2, double rtol=1e-9, atol=0):
    # circle equal?

    cdef double distance
    distance = c2_points_distance(c1.center, c2.center)
    if distance > c1.radius + c2.radius:
        return False
    if distance < fabs(c1.radius - c2.radius):
        return False

    return True


cdef inline bint circle_point_on_perimeter(const CircleData& circle, const C2Data& point, double rtol=1e-9, atol=0):
    return fapprox(circle_equation(circle, point), circle.radius ** 2, rtol, atol)

cdef inline bint circle_point_inside(const CircleData& circle, const C2Data& point):
    return circle_equation(circle, point) < circle.radius ** 2

"""
Cross Type Intersections
"""

cdef inline segment_line_interact():
    pass

cdef inline line_circle_intersect():
    pass

cdef inline segment_circle_intersect():
    pass