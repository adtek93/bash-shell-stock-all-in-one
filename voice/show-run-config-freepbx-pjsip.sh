#!/bin/bash
DB=${1:-asterisk}

echo "Chọn chức năng:"
echo "1 - Show outbound chi tiết"
echo "2 - Count outbound (theo trunkid)"
echo "3 - Show inbound routes"
echo "4 - Show extensions config"
read -p "Nhập lựa chọn (1/2/3/4): " choice

case $choice in
  1)
    mysql "$DB" -e "
    SELECT 
        r.route_id,
        r.name AS route_name,
        p.match_pattern_pass,
        p.match_cid,
        t.trunkid,
        t.channelid
    FROM outbound_routes r
    JOIN outbound_route_patterns p ON r.route_id = p.route_id
    JOIN outbound_route_trunks rt ON r.route_id = rt.route_id
    JOIN trunks t ON rt.trunk_id = t.trunkid
    ORDER BY r.route_id, t.trunkid;
    "
    ;;
  2)
    mysql "$DB" -e "
    SELECT 
        sub.trunkid,
        sub.channelid,
        COUNT(*) AS total_count
    FROM (
        SELECT 
            t.trunkid,
            t.channelid
        FROM outbound_routes r
        JOIN outbound_route_patterns p ON r.route_id = p.route_id
        JOIN outbound_route_trunks rt ON r.route_id = rt.route_id
        JOIN trunks t ON rt.trunk_id = t.trunkid
    ) AS sub
    GROUP BY sub.trunkid, sub.channelid
    ORDER BY total_count DESC;
    "
    ;;
  3)
    mysql "$DB" -e "
    SELECT extension, destination, description 
    FROM incoming
    ORDER BY extension;
    "
    ;;
  4)
    mysql "$DB" -e "
    SELECT extension,ringtimer,outboundcid,chanunavail_dest 
    FROM users
    ORDER BY extension DESC;
    "
    ;;
  *)
    echo "Lựa chọn không hợp lệ!"
    ;;
esac
