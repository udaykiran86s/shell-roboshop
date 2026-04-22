 ZONE_ID=$(aws route53 create-hosted-zone \
  --name udaykiran.site \
  --caller-reference "$(date +%s)" \
  --hosted-zone-config Comment="Public Hosted Zone",PrivateZone=false \
  --query 'HostedZone.Id' \
  --output text | cut -d'/' -f3)

echo $ZONE_ID